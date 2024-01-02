// SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
// SPDX-FileCopyrightText: 2020 Tomaz Canabrava <tcanabrava@kde.org>

#include "mobilepower.h"
#include "statisticsprovider.h"

#include <KConfigGroup>
#include <KLocalizedString>
#include <KPluginFactory>
#include <KSharedConfig>

#include <Solid/Battery>

K_PLUGIN_CLASS_WITH_JSON(MobilePower, "kcm_mobile_power.json")

enum {
    THIRTY_SECONDS,
    ONE_MINUTE,
    TWO_MINUTES,
    FIVE_MINUTES,
    TEN_MINUTES,
    FIFTEEN_MINUTES,
    THIRTY_MINUTES,
    NEVER,
};

const QStringList timeValues = {
    i18n("30 sec"),
    i18n("1 min"),
    i18n("2 min"),
    i18n("5 min"),
    i18n("10 min"),
    i18n("15 min"),
    i18n("30 min"),
    i18n("Never"),
};

// Maps the indices of the timeValues indexes
// to seconds.
const QMap<int, qreal> idxToSeconds = {
    {THIRTY_SECONDS, 30},
    {ONE_MINUTE, 60},
    {TWO_MINUTES, 120},
    {FIVE_MINUTES, 300},
    {TEN_MINUTES, 600},
    {FIFTEEN_MINUTES, 900},
    {THIRTY_MINUTES, 1800},
    {NEVER, 0},
};

MobilePower::MobilePower(QObject *parent, const KPluginMetaData &metaData)
    : KQuickConfigModule(parent, metaData)
    , m_batteries{new BatteryModel(this)}
    , m_profilesConfig{KSharedConfig::openConfig("powerdevilrc", KConfig::SimpleConfig | KConfig::CascadeConfig)}
{
    qmlRegisterUncreatableType<BatteryModel>("org.kde.kcm.power.mobile.private", 1, 0, "BatteryModel", QStringLiteral("Use BatteryModel"));
    qmlRegisterUncreatableType<Solid::Battery>("org.kde.kcm.power.mobile.private", 1, 0, "Battery", "");
    qmlRegisterType<StatisticsProvider>("org.kde.kcm.power.mobile.private", 1, 0, "HistoryModel");

    setButtons(KQuickConfigModule::NoAdditionalButton);
    load();
}

void MobilePower::load()
{
    // we assume that the [AC], [Battery], and [LowBattery] groups have the same value
    // (which is done by this kcm)

    KConfigGroup batteryGroup = m_profilesConfig->group("Battery");

    if (batteryGroup.hasGroup("Display")) {
        qDebug() << "[Battery][Display] group is listed";
        KConfigGroup displaySettings = batteryGroup.group("Display");
        m_dimScreenTime = displaySettings.readEntry("DimDisplayIdleTimeoutSec", 30);
        m_dimScreen = displaySettings.readEntry("DimDisplayWhenIdle", true);

        m_screenOffTime = displaySettings.readEntry("TurnOffDisplayIdleTimeoutSec", 60);
        m_screenOff = displaySettings.readEntry("TurnOffDisplayWhenIdle", true);
    } else {
        qDebug() << "[Battery][Display] Group is not listed";
        m_dimScreenTime = 30;
        m_dimScreen = true;
        m_screenOffTime = 60;
        m_screenOff = true;
    }

    if (batteryGroup.hasGroup("SuspendAndShutdown")) {
        qDebug() << "[Battery][SuspendAndShutdown] group is listed";
        KConfigGroup suspendSessionGroup = batteryGroup.group("SuspendAndShutdown");
        m_suspendSessionTime = suspendSessionGroup.readEntry("AutoSuspendIdleTimeoutSec", 300);
    } else {
        qDebug() << "[Battery][SuspendAndShutdown] is not listed";
        m_suspendSessionTime = 300;
    }
}

void MobilePower::save()
{
    // we set all profiles at the same time, since our UI is a simple global toggle
    KConfigGroup acGroup = m_profilesConfig->group("AC");
    KConfigGroup batteryGroup = m_profilesConfig->group("Battery");
    KConfigGroup lowBatteryGroup = m_profilesConfig->group("LowBattery");

    acGroup.group("Display").writeEntry("DimDisplayWhenIdle", m_dimScreen, KConfigGroup::Notify);
    acGroup.group("Display").writeEntry("DimDisplayIdleTimeoutSec", m_dimScreenTime, KConfigGroup::Notify);
    batteryGroup.group("Display").writeEntry("DimDisplayWhenIdle", m_dimScreen, KConfigGroup::Notify);
    batteryGroup.group("Display").writeEntry("DimDisplayIdleTimeoutSec", m_dimScreenTime, KConfigGroup::Notify);
    lowBatteryGroup.group("Display").writeEntry("DimDisplayWhenIdle", m_dimScreen, KConfigGroup::Notify);
    lowBatteryGroup.group("Display").writeEntry("DimDisplayIdleTimeoutSec", m_dimScreenTime, KConfigGroup::Notify);

    acGroup.group("Display").writeEntry("TurnOffDisplayWhenIdle", m_screenOff, KConfigGroup::Notify);
    acGroup.group("Display").writeEntry("TurnOffDisplayIdleTimeoutSec", m_screenOffTime, KConfigGroup::Notify);
    batteryGroup.group("Display").writeEntry("TurnOffDisplayWhenIdle", m_screenOff, KConfigGroup::Notify);
    batteryGroup.group("Display").writeEntry("TurnOffDisplayIdleTimeoutSec", m_screenOffTime, KConfigGroup::Notify);
    lowBatteryGroup.group("Display").writeEntry("TurnOffDisplayWhenIdle", m_screenOff, KConfigGroup::Notify);
    lowBatteryGroup.group("Display").writeEntry("TurnOffDisplayIdleTimeoutSec", m_screenOffTime, KConfigGroup::Notify);

    acGroup.group("SuspendAndShutdown").writeEntry("AutoSuspendIdleTimeoutSec", m_suspendSessionTime, KConfigGroup::Notify);
    batteryGroup.group("SuspendAndShutdown").writeEntry("AutoSuspendIdleTimeoutSec", m_suspendSessionTime, KConfigGroup::Notify);
    lowBatteryGroup.group("SuspendAndShutdown").writeEntry("AutoSuspendIdleTimeoutSec", m_suspendSessionTime, KConfigGroup::Notify);

    m_profilesConfig->sync();
}

QStringList MobilePower::timeOptions() const
{
    return timeValues;
}

void MobilePower::setDimScreenIdx(int idx)
{
    qreal value = idxToSeconds.value(idx);
    qDebug() << "Got the value" << value;

    if (m_dimScreenTime == value) {
        return;
    }

    if (value == 0) {
        qDebug() << "Setting to never dim";
        m_dimScreen = false;
    } else {
        qDebug() << "Setting to dim in " << value << "Minutes";
        m_dimScreen = true;
    }

    m_dimScreenTime = value;
    Q_EMIT dimScreenIdxChanged();
    save();
}

void MobilePower::setScreenOffIdx(int idx)
{
    qreal value = idxToSeconds.value(idx);
    qDebug() << "Got the value" << value;

    if (m_screenOffTime == value) {
        return;
    }

    if (value == 0) {
        qDebug() << "Setting to never screen off";
        m_screenOff = false;
    } else {
        qDebug() << "Setting to screen off in " << value << "Minutes";
        m_screenOff = true;
    }
    m_screenOffTime = value;

    Q_EMIT screenOffIdxChanged();
    save();
}

void MobilePower::setSuspendSessionIdx(int idx)
{
    qreal value = idxToSeconds.value(idx);
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
    }

    return idxToSeconds.key(std::round(m_suspendSessionTime));
}

int MobilePower::dimScreenIdx()
{
    if (!m_dimScreen) {
        return NEVER;
    }

    return idxToSeconds.key(std::round(m_dimScreenTime));
}

int MobilePower::screenOffIdx()
{
    if (!m_screenOff) {
        return NEVER;
    }

    return idxToSeconds.key(std::round(m_screenOffTime));
}

BatteryModel *MobilePower::batteries()
{
    return m_batteries;
}

#include "mobilepower.moc"
