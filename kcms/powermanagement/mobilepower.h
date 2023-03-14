// SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
// SPDX-FileCopyrightText: 2020 Tomaz Canabrava <tcanabrava@kde.org>

#pragma once

#include "batterymodel.h"

#include <KQuickAddons/ConfigModule>
#include <KSharedConfig>
#include <memory>

class MobilePower : public KQuickAddons::ConfigModule
{
    Q_OBJECT
    Q_PROPERTY(BatteryModel *batteries READ batteries CONSTANT)
    Q_PROPERTY(int dimScreenIdx READ dimScreenIdx WRITE setDimScreenIdx NOTIFY dimScreenIdxChanged)
    Q_PROPERTY(int screenOffIdx READ screenOffIdx WRITE setScreenOffIdx NOTIFY screenOffIdxChanged)
    Q_PROPERTY(int suspendSessionIdx READ suspendSessionIdx WRITE setSuspendSessionIdx NOTIFY suspendSessionIdxChanged)

public:
    MobilePower(QObject *parent, const KPluginMetaData &metaData, const QVariantList &args);
    ~MobilePower();

    Q_INVOKABLE QStringList timeOptions() const;

    void setDimScreenIdx(int idx);
    void setScreenOffIdx(int idx);
    void setSuspendSessionIdx(int idx);
    int dimScreenIdx();
    int screenOffIdx();
    int suspendSessionIdx();

    BatteryModel *batteries();

    Q_SIGNAL void dimScreenIdxChanged();
    Q_SIGNAL void screenOffIdxChanged();
    Q_SIGNAL void suspendSessionIdxChanged();

    QString stringForValue(int value);

    void load() override;
    void save() override;

private:
    BatteryModel *m_batteries;
    KSharedConfig::Ptr m_profilesConfig;

    qreal m_suspendSessionTime;
    qreal m_dimScreenTime;
    qreal m_screenOffTime;
};
