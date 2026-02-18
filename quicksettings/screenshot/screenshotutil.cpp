/*
 * SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>
 * SPDX-FileCopyrightText: 2018 Bhushan Shah <bshah@kde.org>
 * SPDX-FileCopyrightText: 2022 by Devin Lin <devin@kde.org>
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

#include "screenshotutil.h"

#include <fcntl.h>
#include <qplatformdefs.h>
#include <unistd.h>

#include <KLocalizedString>
#include <KNotification>

#include <QGuiApplication>
#include <QImage>
#include <QScreen>
#include <QTimer>
#include <QtConcurrent/QtConcurrentRun>

constexpr int SCREENSHOT_DELAY = 200;

/* -- Static Helpers --------------------------------------------------------------------------- */

static QImage allocateImage(const QVariantMap &metadata)
{
    bool ok;

    const uint width = metadata.value(QStringLiteral("width")).toUInt(&ok);
    if (!ok) {
        return QImage();
    }

    const uint height = metadata.value(QStringLiteral("height")).toUInt(&ok);
    if (!ok) {
        return QImage();
    }

    const uint format = metadata.value(QStringLiteral("format")).toUInt(&ok);
    if (!ok) {
        return QImage();
    }

    return QImage(width, height, QImage::Format(format));
}

static QImage readImage(int fileDescriptor, const QVariantMap &metadata)
{
    QFile file;
    if (!file.open(fileDescriptor, QFileDevice::ReadOnly, QFileDevice::AutoCloseHandle)) {
        close(fileDescriptor);
        return QImage();
    }

    QImage result = allocateImage(metadata);
    if (result.isNull()) {
        return QImage();
    }

    QDataStream stream(&file);
    stream.readRawData(reinterpret_cast<char *>(result.bits()), result.sizeInBytes());

    return result;
}

ScreenShotUtil::ScreenShotUtil(QObject *parent)
    : QObject{parent}
{
    m_screenshotInterface = new OrgKdeKWinScreenShot2Interface(QStringLiteral("org.kde.KWin.ScreenShot2"),
                                                               QStringLiteral("/org/kde/KWin/ScreenShot2"),
                                                               QDBusConnection::sessionBus(),
                                                               this);
}

void ScreenShotUtil::takeScreenShot()
{
    // wait ~200 ms to wait for rest of animations
    QTimer::singleShot(SCREENSHOT_DELAY, [this]() {
        int lPipeFds[2];
        if (pipe2(lPipeFds, O_CLOEXEC) != 0) {
            qWarning() << "Could not take screenshot";
            return;
        }

        // We don't have access to the ScreenPool so we'll just take the first screen
        QVariantMap options;
        options.insert(QStringLiteral("native-resolution"), true);
        options.insert(QStringLiteral("hide-caller-windows"), false);

        auto pendingCall = m_screenshotInterface->CaptureScreen(qGuiApp->screens().constFirst()->name(), options, QDBusUnixFileDescriptor(lPipeFds[1]));
        close(lPipeFds[1]);
        auto pipeFileDescriptor = lPipeFds[0];

        auto watcher = new QDBusPendingCallWatcher(pendingCall, this);
        connect(watcher, &QDBusPendingCallWatcher::finished, this, [this, watcher, pipeFileDescriptor]() {
            watcher->deleteLater();
            const QDBusPendingReply<QVariantMap> reply = *watcher;

            if (reply.isError()) {
                qWarning() << "Screenshot request failed:" << reply.error().message();
            } else {
                handleMetaDataReceived(reply, pipeFileDescriptor);
            }
        });
    });
}

void ScreenShotUtil::handleMetaDataReceived(const QVariantMap &metadata, int fd)
{
    const QString type = metadata.value(QStringLiteral("type")).toString();
    if (type != QLatin1String("raw")) {
        qWarning() << "Unsupported metadata type:" << type;
        return;
    }

    auto watcher = new QFutureWatcher<QImage>(this);
    connect(watcher, &QFutureWatcher<QImage>::finished, this, [watcher]() {
        watcher->deleteLater();

        QString filePath = QStandardPaths::writableLocation(QStandardPaths::PicturesLocation);
        if (filePath.isEmpty()) {
            qWarning() << "Couldn't find a writable location for the screenshot!";
            return;
        }
        QDir picturesDir(filePath);
        if (!picturesDir.mkpath(QStringLiteral("Screenshots"))) {
            qWarning() << "Couldn't create folder at" << picturesDir.path() + QStringLiteral("/Screenshots") << "to take screenshot.";
            return;
        }
        filePath += QStringLiteral("/Screenshots/Screenshot_%1.png").arg(QDateTime::currentDateTime().toString(QStringLiteral("yyyyMMdd_hhmmss")));
        const auto m_result = watcher->result();
        if (m_result.isNull() || !m_result.save(filePath)) {
            qWarning() << "Screenshot failed";
        } else {
            KNotification *notif = new KNotification("captured");
            notif->setComponentName(QStringLiteral("plasma_mobile_quicksetting_screenshot"));
            notif->setTitle(i18n("New Screenshot"));
            notif->setUrls({QUrl::fromLocalFile(filePath)});
            notif->setText(i18n("New screenshot saved to %1", filePath));
            notif->sendEvent();
        }
    });
    watcher->setFuture(QtConcurrent::run(readImage, fd, metadata));
}
