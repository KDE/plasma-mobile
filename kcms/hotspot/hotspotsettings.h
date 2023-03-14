/*
    SPDX-FileCopyrightText: 2020 Tobias Fella <fella@posteo.de>

    SPDX-License-Identifier: LGPL-2.0-or-later
*/

#ifndef HOTSPOTSETTINGS_H
#define HOTSPOTSETTINGS_H

#include <KQuickAddons/ConfigModule>

class HotspotSettings : public KQuickAddons::ConfigModule
{
    Q_OBJECT
public:
    HotspotSettings(QObject *parent, const KPluginMetaData &metaData, const QVariantList &args);
    virtual ~HotspotSettings() override;
};

#endif // HOTSPOTSETTINGS_H
