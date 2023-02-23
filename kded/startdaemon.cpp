// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include <KIO/CommandLauncherJob>
#include <KNotificationJobUiDelegate>
#include <KPluginFactory>
#include <KPluginLoader>

#include <QProcess>

#include "settings.h"
#include "startdaemon.h"

K_PLUGIN_CLASS_WITH_JSON(PlasmaMobileStartDaemon, "kded_plasma-mobile-start.json")

PlasmaMobileStartDaemon::PlasmaMobileStartDaemon(QObject *parent, const QList<QVariant> &)
    : KDEDModule{parent}
{
    // apply configuration
    Settings::self()->applyConfiguration();
}

#include "startdaemon.moc"
