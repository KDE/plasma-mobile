/*

    SPDX-FileCopyrightText: 2011-2015 Sebastian Kügler <sebas@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

#ifndef TIMESETTINGS_H
#define TIMESETTINGS_H

#include <QDate>
#include <QIcon>
#include <QObject>
#include <QStringListModel>
#include <QTime>
#include <QVariant>

#include <KConfigGroup>
#include <KSharedConfig>

#include <KQuickConfigModule>

#include <QCoroQmlTask>
#include <QCoroTask>

#include "timedated_interface.h"
#include "timezonemodel.h"

// #include "settingsmodule.h"

class TimeSettingsPrivate;

/**
 * @class TimeSettings A class to manage time and date related settings. This class serves two functions:
 * - Provide a plugin implementation
 * - Provide a settings module
 * This is done from one class in order to simplify the code. You can export any QObject-based
 * class through qmlRegisterType(), however.
 */
class TimeSettings : public KQuickConfigModule
{
    Q_OBJECT

    Q_PROPERTY(QString timeFormat READ timeFormat WRITE setTimeFormat NOTIFY timeFormatChanged)
    Q_PROPERTY(bool twentyFour READ twentyFour WRITE setTwentyFour NOTIFY twentyFourChanged)
    Q_PROPERTY(QString timeZone READ timeZone WRITE setTimeZone NOTIFY timeZoneChanged)
    Q_PROPERTY(TimeZoneFilterProxy *timeZonesModel READ timeZonesModel WRITE setTimeZonesModel NOTIFY timeZonesModelChanged)
    Q_PROPERTY(QTime currentTime READ currentTime WRITE setCurrentTime NOTIFY currentTimeChanged)
    Q_PROPERTY(QDate currentDate READ currentDate WRITE setCurrentDate NOTIFY currentDateChanged)
    Q_PROPERTY(bool useNtp READ useNtp WRITE setUseNtp NOTIFY useNtpChanged)
    Q_PROPERTY(QString currentTimeText READ currentTimeText NOTIFY currentTimeTextChanged)
    Q_PROPERTY(QString errorString READ errorString NOTIFY errorStringChanged)

public:
    TimeSettings(QObject *parent, const KPluginMetaData &metaData);

    QString currentTimeText();
    QTime currentTime() const;
    void setCurrentTime(const QTime &time);

    QDate currentDate() const;
    void setCurrentDate(const QDate &date);

    bool useNtp() const;
    void setUseNtp(bool ntp);

    QString timeFormat();
    QString timeZone();
    TimeZoneFilterProxy *timeZonesModel();
    bool twentyFour();

    QString errorString();

public Q_SLOTS:
    void setTimeZone(const QString &timezone);
    void setTimeZonesModel(TimeZoneFilterProxy *timezones);
    void setTimeFormat(const QString &timeFormat);
    void setTwentyFour(bool t);
    void timeout();
    void saveTime();
    void notify();
    void saveTimeZone(const QString &newtimezone);

Q_SIGNALS:
    void currentTimeTextChanged();
    void currentTimeChanged();
    void currentDateChanged();
    void twentyFourChanged();
    void timeFormatChanged();
    void timeZoneChanged();
    void timeZonesChanged();
    void timeZonesModelChanged();
    void useNtpChanged();
    void errorStringChanged();

protected:
    QString findNtpUtility();

private:
    QString m_timeFormat;
    QString m_timezone;
    TimeZoneFilterProxy *m_timeZonesModel;
    QString m_timeZoneFilter;
    QString m_currentTimeText;
    QTime m_currentTime;
    QDate m_currentDate;
    bool m_useNtp;
    QString m_errorString;

    void initTimeZones();

    KSharedConfig::Ptr m_localeConfig;
    KConfigGroup m_localeSettings;
    std::shared_ptr<OrgFreedesktopTimedate1Interface> m_timedateIface{nullptr};
};

#endif // TIMESETTINGS_H
