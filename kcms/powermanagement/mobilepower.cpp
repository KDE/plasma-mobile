// SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
// SPDX-FileCopyrightText: 2020 Tomaz Canabrava <tcanabrava@kde.org>

#include "mobilepower.h"
#include "statisticsprovider.h"

#include <KConfigGroup>
#include <KLocalizedString>
#include <KPluginFactory>
#include <KSharedConfig>

#include <Solid/Battery>

K_PLUGIN_CLASS_WITH_JSON(MobilePower, "powermanagement.json")

enum {
    THIRTY_SECONDS,
    ONE_MINUTE,
    TWO_MINUTES,
    FIVE_MINUTES,
    TEN_MINUTES,
    FIFTEEN_MINUTES,
    NEVER,
};

const QStringList timeValues = {
    i18n("30 sec"),
    i18n("1 min"),
    i18n("2 min"),
    i18n("5 min"),
    i18n("10 min"),
    i18n("15 min"),
    i18n("Never"),
};

// Maps the indices of the timeValues indexes
// to minutes.
const QMap<int, qreal> idxToMinutes = {
    {THIRTY_SECONDS, 0.5},
    {ONE_MINUTE, 1},
    {TWO_MINUTES, 2},
    {FIVE_MINUTES, 5},
    {TEN_MINUTES, 10},
    {FIFTEEN_MINUTES, 15},
    {NEVER, 0},
};

MobilePower::MobilePower(QObject *parent, const KPluginMetaData &metaData, const QVariantList &args)
    : KQuickAddons::ConfigModule(parent, metaData, args)
    , m_batteries{new BatteryModel(this)}
    , m_profilesConfig{KSharedConfig::openConfig("powermanagementprofilesrc", KConfig::SimpleConfig | KConfig::CascadeConfig)}
{
    qmlRegisterUncreatableType<BatteryModel>("org.kde.kcm.power.mobile.private", 1, 0, "BatteryModel", QStringLiteral("Use BatteryModel"));
    qmlRegisterUncreatableType<Solid::Battery>("org.kde.kcm.power.mobile.private", 1, 0, "Battery", "");
    qmlRegisterType<StatisticsProvider>("org.kde.kcm.power.mobile.private", 1, 0, "HistoryModel");

    setButtons(KQuickAddons::ConfigModule::NoAdditionalButton);
    load();
}

MobilePower::~MobilePower() = default;

// contents of powermanagementprofilesrc
//
// [Battery][SuspendSession] // our LockScreen
// idleTime=600000
// suspendThenHibernate = enabled / disabled.
// suspendType=1
// type 1 = sleep
// type 8 = shutdown
// type 32 = lock screen
//
// [Battery][DimDisplay] // our "Sleep Screen"
// idleTime=300000
// Aparently KDE removes this group when it's false.
//

void MobilePower::load()
{
    // we assume that the [AC], [Battery], and [LowBattery] groups have the same value
    // (which is done by this kcm)

    KConfigGroup batteryGroup = m_profilesConfig->group("Battery");

    if (batteryGroup.hasGroup("DimDisplay")) {
        qDebug() << "[Battery][DimDisplay] group is listed";
        KConfigGroup dimSettings = batteryGroup.group("DimDisplay");

        // powerdevil/dimdisplayconfig.cpp - here we load time / 60 / 1000
        // We should really, really, stop doing that.
        m_dimScreenTime = (dimSettings.readEntry("idleTime").toDouble() / 60) / 1000;
    } else {
        qDebug() << "[Battery][DimDisplay] Group is not listed";
        m_dimScreenTime = 0;
    }

    if (batteryGroup.hasGroup("DPMSControl")) {
        qDebug() << "[Battery][DPMSControl] group is listed";
        KConfigGroup dpmsSettings = batteryGroup.group("DPMSControl");
        m_screenOffTime = dpmsSettings.readEntry("idleTime").toDouble() / 60 / 1000;
    } else {
        qDebug() << "[Battery][DPMSControl] is not listed";
        m_screenOffTime = 0;
    }

    if (batteryGroup.hasGroup("SuspendSession")) {
        qDebug() << "[Battery][SuspendSession] group is listed";
        KConfigGroup suspendSessionGroup = batteryGroup.group("SuspendSession");
        m_suspendSessionTime = suspendSessionGroup.readEntry("idleTime").toDouble() / 60 / 1000;
    } else {
        qDebug() << "[Battery][SuspendSession] is not listed";
        m_suspendSessionTime = 0;
    }
}

void MobilePower::save()
{
    // we set all profiles at the same time, since our UI is quite a simple global toggle
    KConfigGroup acGroup = m_profilesConfig->group("AC");
    KConfigGroup batteryGroup = m_profilesConfig->group("Battery");
    KConfigGroup lowBatteryGroup = m_profilesConfig->group("LowBattery");

    if (m_dimScreenTime == 0) {
        qDebug() << "Deleting the group DimDisplay";

        acGroup.deleteGroup("DimDisplay", KConfigGroup::Notify);
        batteryGroup.deleteGroup("DimDisplay", KConfigGroup::Notify);
        lowBatteryGroup.deleteGroup("DimDisplay", KConfigGroup::Notify);
    } else {
        // powerdevil/dimdisplayconfig.cpp - here we store time * 60 * 1000
        // We should really, really, stop doing that.
        acGroup.group("DimDisplay").writeEntry("idleTime", m_dimScreenTime * 60 * 1000, KConfigGroup::Notify);
        batteryGroup.group("DimDisplay").writeEntry("idleTime", m_dimScreenTime * 60 * 1000, KConfigGroup::Notify);
        lowBatteryGroup.group("DimDisplay").writeEntry("idleTime", m_dimScreenTime * 60 * 1000, KConfigGroup::Notify);
    }

    if (m_screenOffTime == 0) {
        qDebug() << "Deleting the group DPMSControl";

        acGroup.deleteGroup("DPMSControl", KConfigGroup::Notify);
        batteryGroup.deleteGroup("DPMSControl", KConfigGroup::Notify);
        lowBatteryGroup.deleteGroup("DPMSControl", KConfigGroup::Notify);
    } else {
        acGroup.group("DPMSControl").writeEntry("idleTime", m_screenOffTime * 60 * 1000, KConfigGroup::Notify);
        batteryGroup.group("DPMSControl").writeEntry("idleTime", m_screenOffTime * 60 * 1000, KConfigGroup::Notify);
        lowBatteryGroup.group("DPMSControl").writeEntry("idleTime", m_screenOffTime * 60 * 1000, KConfigGroup::Notify);
    }

    // ensure the system is locked when the screen is turned off
    acGroup.group("DPMSControl").writeEntry("lockBeforeTurnOff", 1, KConfigGroup::Notify);
    batteryGroup.group("DPMSControl").writeEntry("lockBeforeTurnOff", 1, KConfigGroup::Notify);
    lowBatteryGroup.group("DPMSControl").writeEntry("lockBeforeTurnOff", 1, KConfigGroup::Notify);

    if (m_suspendSessionTime == 0) {
        qDebug() << "Deleting the group SuspendDisplay";

        acGroup.deleteGroup("SuspendSession", KConfigGroup::Notify);
        batteryGroup.deleteGroup("SuspendSession", KConfigGroup::Notify);
        lowBatteryGroup.deleteGroup("SuspendSession", KConfigGroup::Notify);
    } else {
        acGroup.group("SuspendSession").writeEntry("idleTime", m_suspendSessionTime * 60 * 1000, KConfigGroup::Notify);
        acGroup.group("SuspendSession").writeEntry("suspendType", 1, KConfigGroup::Notify);

        batteryGroup.group("SuspendSession").writeEntry("idleTime", m_suspendSessionTime * 60 * 1000, KConfigGroup::Notify);
        batteryGroup.group("SuspendSession").writeEntry("suspendType", 1, KConfigGroup::Notify);

        lowBatteryGroup.group("SuspendSession").writeEntry("idleTime", m_suspendSessionTime * 60 * 1000, KConfigGroup::Notify);
        lowBatteryGroup.group("SuspendSession").writeEntry("suspendType", 1, KConfigGroup::Notify);
    }

    m_profilesConfig->sync();
    // Do not mess with Suspend Type
    // suspendSessionGroup.writeEntry("suspendType", 32); // always lock screen.
}

QStringList MobilePower::timeOptions() const
{
    return timeValues;
}

void MobilePower::setDimScreenIdx(int idx)
{
    qreal value = idxToMinutes.value(idx);
    qDebug() << "Got the value" << value;

    if (m_dimScreenTime == value) {
        return;
    }

    if (value == 0) {
        qDebug() << "Setting to never dim";
    } else {
        qDebug() << "Setting to dim in " << value << "Minutes";
    }

    m_dimScreenTime = value;
    Q_EMIT dimScreenIdxChanged();
    save();
}

void MobilePower::setScreenOffIdx(int idx)
{
    qreal value = idxToMinutes.value(idx);
    qDebug() << "Got the value" << value;

    if (m_screenOffTime == value) {
        return;
    }

    if (value == 0) {
        qDebug() << "Setting to never screen off";
    } else {
        qDebug() << "Setting to screen off in " << value << "Minutes";
    }
    m_screenOffTime = value;

    Q_EMIT screenOffIdxChanged();
    save();
}

void MobilePower::setSuspendSessionIdx(int idx)
{
    qreal value = idxToMinutes.value(idx);
    qDebug() << "Got the value" << value;

    if (m_suspendSessionTime == value) {
        return;
    }

    if (value == 0) {
        qDebug() << "Setting to never suspend";
    } else {
        qDebug() << "Setting to suspend in " << value << "Minutes";
    }

    m_suspendSessionTime = value;
    Q_EMIT suspendSessionIdxChanged();
    save();
}

int MobilePower::suspendSessionIdx()
{
    if (m_suspendSessionTime == 0) {
        return NEVER;
    } else if (qFuzzyIsNull(m_suspendSessionTime)) {
        return NEVER;
    } else if (qFuzzyCompare(m_suspendSessionTime, 0.5)) {
        return THIRTY_SECONDS;
    }

    return idxToMinutes.key(std::round(m_suspendSessionTime));
}

int MobilePower::dimScreenIdx()
{
    if (m_dimScreenTime == 0) {
        return NEVER;
    } else if (qFuzzyIsNull(m_dimScreenTime)) {
        return NEVER;
    } else if (qFuzzyCompare(m_dimScreenTime, 0.5)) {
        return THIRTY_SECONDS;
    }

    return idxToMinutes.key(std::round(m_dimScreenTime));
}

int MobilePower::screenOffIdx()
{
    if (m_screenOffTime == 0) {
        return NEVER;
    } else if (qFuzzyIsNull(m_screenOffTime)) {
        return NEVER;
    } else if (qFuzzyCompare(m_screenOffTime, 0.5)) {
        return THIRTY_SECONDS;
    }

    return idxToMinutes.key(std::round(m_screenOffTime));
}

BatteryModel *MobilePower::batteries()
{
    return m_batteries;
}

#include "mobilepower.moc"
