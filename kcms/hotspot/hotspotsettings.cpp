/*
    SPDX-FileCopyrightText: 2020 Tobias Fella <fella@posteo.de>

    SPDX-License-Identifier: LGPL-2.0-or-later
*/

#include <KLocalizedString>
#include <KPluginFactory>

#include <KQuickConfigModule>

class HotspotSettings : public KQuickConfigModule
{
    Q_OBJECT
public:
    HotspotSettings(QObject *parent, const KPluginMetaData &metaData)
        : KQuickConfigModule(parent, metaData)
    {
    }
};

K_PLUGIN_CLASS_WITH_JSON(HotspotSettings, "kcm_mobile_hotspot.json")

#include "hotspotsettings.moc"
