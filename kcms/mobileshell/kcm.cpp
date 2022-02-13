/**
 * SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

#include "kcm.h"

#include <KPluginFactory>

K_PLUGIN_CLASS_WITH_JSON(KCMMobileShell, "metadata.json")

const QString CONFIG_FILE = QStringLiteral("plasmamobilerc");
const QString GENERAL_CONFIG_GROUP = QStringLiteral("General");

KCMMobileShell::KCMMobileShell(QObject *parent, const KPluginMetaData &data, const QVariantList &args)
    : KQuickAddons::ManagedConfigModule(parent, data, args)
    , m_config{KSharedConfig::openConfig("plasmamobilerc", KConfig::SimpleConfig)}
{
    setButtons(0);
}

bool KCMMobileShell::navigationPanelEnabled() const
{
    auto group = KConfigGroup{m_config, GENERAL_CONFIG_GROUP};
    return group.readEntry("navigationPanelEnabled", true);
}

void KCMMobileShell::setNavigationPanelEnabled(bool navigationPanelEnabled)
{
    auto group = KConfigGroup{m_config, GENERAL_CONFIG_GROUP};
    group.writeEntry("navigationPanelEnabled", navigationPanelEnabled, KConfigGroup::Notify);
    m_config->sync();
}

#include "kcm.moc"
