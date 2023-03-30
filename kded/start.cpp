// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include <KIO/CommandLauncherJob>
#include <KNotificationJobUiDelegate>
#include <KPluginFactory>

#include <QProcess>

#include "start.h"

PlasmaMobileStartDaemon::PlasmaMobileStartDaemon(QObject *parent, const QList<QVariant> &)
    : KDEDModule{parent}
{
    auto *job = new KIO::CommandLauncherJob(QStringLiteral("plasma-mobile-envmanager --apply-settings"), {});
    job->setUiDelegate(new KNotificationJobUiDelegate(KJobUiDelegate::AutoErrorHandlingEnabled));
    job->setDesktopName(QStringLiteral("org.kde.plasma-mobile-envmanager"));
    job->start();
}

#include "start.moc"
