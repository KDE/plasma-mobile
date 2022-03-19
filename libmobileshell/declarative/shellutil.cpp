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

ShellUtil::ShellUtil(QObject *parent)
    : QObject{parent}
{
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
