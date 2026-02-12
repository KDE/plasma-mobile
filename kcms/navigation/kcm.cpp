/**
 * SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

#include <KPluginFactory>

#include <KConfigGroup>
#include <KQuickManagedConfigModule>
#include <KSharedConfig>

class KCMMobileShell : public KQuickManagedConfigModule
{
    Q_OBJECT

public:
    KCMMobileShell(QObject *parent, const KPluginMetaData &data)
        : KQuickManagedConfigModule(parent, data)
    {
        setButtons({});
    }

Q_SIGNALS:
    void navigationPanelEnabledChanged();

private:
    KSharedConfig::Ptr m_config;
};

K_PLUGIN_CLASS_WITH_JSON(KCMMobileShell, "kcm_navigation.json")

#include "kcm.moc"
