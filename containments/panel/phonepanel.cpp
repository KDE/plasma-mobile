/*
 *   SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>
 *   SPDX-FileCopyrightText: 2018 Bhushan Shah <bshah@kde.org>
 *
 *   SPDX-License-Identifier: GPL-2.0-or-later
 */

#include "phonepanel.h"

#include <fcntl.h>
#include <qplatformdefs.h>
#include <unistd.h>

#include <KConfigGroup>
#include <KIO/ApplicationLauncherJob>
#include <KLocalizedString>
#include <KNotification>

#include <QDBusPendingReply>
#include <QDateTime>
#include <QDebug>
#include <QFile>
#include <QGuiApplication>
#include <QProcess>
#include <QScreen>
#include <QStandardPaths>
#include <QtConcurrent/QtConcurrent>

#define FORMAT24H "HH:mm:ss"

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

PhonePanel::PhonePanel(QObject *parent, const QVariantList &args)
    : Plasma::Containment(parent, args)
{
    // setHasConfigurationInterface(true);
    m_kscreenInterface = new org::kde::KScreen(QStringLiteral("org.kde.kded5"), QStringLiteral("/modules/kscreen"), QDBusConnection::sessionBus(), this);
    m_screenshotInterface = new OrgKdeKWinScreenShot2Interface(QStringLiteral("org.kde.KWin.ScreenShot2"),
                                                               QStringLiteral("/org/kde/KWin/ScreenShot2"),
                                                               QDBusConnection::sessionBus(),
                                                               this);

    m_localeConfig = KSharedConfig::openConfig(QStringLiteral("kdeglobals"), KConfig::SimpleConfig);
    m_localeConfigWatcher = KConfigWatcher::create(m_localeConfig);

    // watch for changes to locale config, to update 12/24 hour time
    connect(m_localeConfigWatcher.data(), &KConfigWatcher::configChanged, this, [this](const KConfigGroup &group, const QByteArrayList &names) -> void {
        if (group.name() == "Locale") {
            // we have to reparse for new changes (from system settings)
            m_localeConfig->reparseConfiguration();
            Q_EMIT isSystem24HourFormatChanged();
        }
    });
}

PhonePanel::~PhonePanel() = default;

void PhonePanel::executeCommand(const QString &command)
{
    qWarning() << "Executing" << command;
    const QStringList commandAndArguments = QProcess::splitCommand(command);
    QProcess::startDetached(commandAndArguments.front(), commandAndArguments.mid(1));
}

void PhonePanel::toggleTorch()
{
    // FIXME this is hardcoded to the PinePhone for now
    static auto FLASH_SYSFS_PATH = "/sys/devices/platform/led-controller/leds/white:flash/brightness";
    int fd = open(FLASH_SYSFS_PATH, O_WRONLY);

    if (fd < 0) {
        qWarning() << "Unable to open file %s" << FLASH_SYSFS_PATH;
        return;
    }

    write(fd, m_running ? "0" : "1", 1);
    close(fd);
    m_running = !m_running;
    Q_EMIT torchChanged(m_running);
}
bool PhonePanel::torchEnabled() const
{
    return m_running;
}
bool PhonePanel::autoRotate()
{
    QDBusPendingReply<bool> reply = m_kscreenInterface->getAutoRotate();
    reply.waitForFinished();
    if (reply.isError()) {
        qWarning() << "Getting auto rotate failed:" << reply.error().name() << reply.error().message();
        return false;
    } else {
        return reply.value();
    }
}

void PhonePanel::setAutoRotate(bool value)
{
    QDBusPendingReply<> reply = m_kscreenInterface->setAutoRotate(value);
    reply.waitForFinished();
    if (reply.isError()) {
        qWarning() << "Setting auto rotate failed:" << reply.error().name() << reply.error().message();
    } else {
        emit autoRotateChanged(value);
    }
}

void PhonePanel::handleMetaDataReceived(const QVariantMap &metadata, int fd)
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
            notif->setComponentName(QStringLiteral("plasma_phone_components"));
            notif->setTitle(i18n("New Screenshot"));
            notif->setUrls({filePath});
            notif->setText(i18n("New screenshot saved to %1", filePath));
            notif->sendEvent();
        }
    });
    watcher->setFuture(QtConcurrent::run(readImage, fd, metadata));
}

void PhonePanel::takeScreenshot()
{
    // wait ~200 ms to wait for rest of animations
    QTimer::singleShot(SCREENSHOT_DELAY, [=]() {
        int lPipeFds[2];
        if (pipe2(lPipeFds, O_CLOEXEC) != 0) {
            qWarning() << "Could not take screenshot";
            return;
        }

        // We don't have access to the ScreenPool so we'll just take the first screen
        auto pendingCall = m_screenshotInterface->CaptureScreen(qGuiApp->screens().constFirst()->name(), {}, QDBusUnixFileDescriptor(lPipeFds[1]));
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

bool PhonePanel::isSystem24HourFormat()
{
    KConfigGroup localeSettings = KConfigGroup(m_localeConfig, "Locale");

    QString timeFormat = localeSettings.readEntry("TimeFormat", QStringLiteral(FORMAT24H));
    return timeFormat == QStringLiteral(FORMAT24H);
}

void PhonePanel::launchApp(const QString &app)
{
    const KService::Ptr appService = KService::serviceByDesktopName(app);
    if (!appService) {
        qWarning() << "Could not find" << app;
        return;
    }
    auto job = new KIO::ApplicationLauncherJob(appService, this);
    job->start();
}

K_PLUGIN_CLASS_WITH_JSON(PhonePanel, "metadata.json")

#include "phonepanel.moc"
