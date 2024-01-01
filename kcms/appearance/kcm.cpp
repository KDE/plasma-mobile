/**
 * SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

#include <KPluginFactory>

#include <KConfigGroup>
#include <KQuickManagedConfigModule>
#include <KSharedConfig>

class KCMMobileAppearance : public KQuickManagedConfigModule
{
    Q_OBJECT

public:
    KCMMobileAppearance(QObject *parent, const KPluginMetaData &data)
        : KQuickManagedConfigModule(parent, data)
    {
        setButtons({});
    }
};

K_PLUGIN_CLASS_WITH_JSON(KCMMobileAppearance, "kcm_mobileappearance.json")

#include "kcm.moc"
