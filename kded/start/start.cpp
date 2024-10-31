// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include <KIO/CommandLauncherJob>
#include <KNotificationJobUiDelegate>
#include <KPluginFactory>

#include "start.h"

K_PLUGIN_FACTORY_WITH_JSON(StartFactory, "kded_plasma_mobile_start.json", registerPlugin<Start>();)

Start::Start(QObject *parent, const QList<QVariant> &)
    : KDEDModule{parent}
{
    auto *envmanagerJob = new KIO::CommandLauncherJob(QStringLiteral("plasma-mobile-envmanager --apply-settings"), {});
    envmanagerJob->setUiDelegate(new KNotificationJobUiDelegate(KJobUiDelegate::AutoErrorHandlingEnabled));
    envmanagerJob->setDesktopName(QStringLiteral("org.kde.plasma-mobile-envmanager"));
    envmanagerJob->start();

    auto *initialstartJob = new KIO::CommandLauncherJob(QStringLiteral("plasma-mobile-initial-start"), {});
    initialstartJob->setUiDelegate(new KNotificationJobUiDelegate(KJobUiDelegate::AutoErrorHandlingEnabled));
    initialstartJob->setDesktopName(QStringLiteral("org.kde.plasma-mobile-initial-start"));
    initialstartJob->start();
}

#include "start.moc"
