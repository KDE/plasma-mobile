/*
 *  SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>
 *  SPDX-FileCopyrightText: 2018 Bhushan Shah <bshah@kde.org>
 *  SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

#include "shellutil.h"

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

using namespace MobileShell;

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

ShellUtil::ShellUtil(QObject *parent)
    : QObject{parent}
{
    // setHasConfigurationInterface(true);
    m_kscreenInterface = new org::kde::KScreen(QStringLiteral("org.kde.kded5"), QStringLiteral("/modules/kscreen"), QDBusConnection::sessionBus(), this);

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

ShellUtil::~ShellUtil() = default;

ShellUtil *ShellUtil::instance()
{
    static ShellUtil *inst = new ShellUtil(nullptr);
    return inst;
}

void ShellUtil::executeCommand(const QString &command)
{
    qWarning() << "Executing" << command;
    const QStringList commandAndArguments = QProcess::splitCommand(command);
    QProcess::startDetached(commandAndArguments.front(), commandAndArguments.mid(1));
}

void ShellUtil::toggleTorch()
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

bool ShellUtil::torchEnabled() const
{
    return m_running;
}

bool ShellUtil::autoRotate()
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

void ShellUtil::setAutoRotate(bool value)
{
    QDBusPendingReply<> reply = m_kscreenInterface->setAutoRotate(value);
    reply.waitForFinished();
    if (reply.isError()) {
        qWarning() << "Setting auto rotate failed:" << reply.error().name() << reply.error().message();
    } else {
        emit autoRotateChanged(value);
    }
}

bool ShellUtil::isSystem24HourFormat()
{
    KConfigGroup localeSettings = KConfigGroup(m_localeConfig, "Locale");

    QString timeFormat = localeSettings.readEntry("TimeFormat", QStringLiteral(FORMAT24H));
    return timeFormat == QStringLiteral(FORMAT24H);
}

void ShellUtil::launchApp(const QString &app)
{
    const KService::Ptr appService = KService::serviceByDesktopName(app);
    if (!appService) {
        qWarning() << "Could not find" << app;
        return;
    }
    auto job = new KIO::ApplicationLauncherJob(appService, this);
    job->start();
}
