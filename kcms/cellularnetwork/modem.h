// SPDX-FileCopyrightText: 2021-2022 Devin Lin <espidev@gmail.com>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include "cellularnetworksettings.h"
#include "modemdetails.h"
#include "profilesettings.h"
#include "sim.h"

#include <QList>
#include <QString>

#include <NetworkManagerQt/CdmaSetting>
#include <NetworkManagerQt/ConnectionSettings>
#include <NetworkManagerQt/GsmSetting>
#include <NetworkManagerQt/Manager>
#include <NetworkManagerQt/ModemDevice>
#include <NetworkManagerQt/Settings>

#include <ModemManagerQt/GenericTypes>
#include <ModemManagerQt/Manager>
#include <ModemManagerQt/Modem3Gpp>
#include <ModemManagerQt/ModemDevice>

#include <QCoroDBusPendingReply>

class ProfileSettings;
class Sim;
class AvailableNetwork;
class ModemDetails;
class MobileProviders;

// only supports GSM/UMTS/LTE
class Modem : public QObject
{
    Q_OBJECT
    Q_PROPERTY(ModemDetails *details READ modemDetails NOTIFY modemDetailsChanged)
    Q_PROPERTY(QString uni READ uni NOTIFY uniChanged)
    Q_PROPERTY(QString displayId READ displayId NOTIFY displayIdChanged)

    Q_PROPERTY(bool isRoaming READ isRoaming WRITE setIsRoaming NOTIFY isRoamingChanged)
    Q_PROPERTY(bool hasSim READ hasSim NOTIFY hasSimChanged)
    Q_PROPERTY(QList<ProfileSettings *> profiles READ profileList NOTIFY profileListChanged)
    Q_PROPERTY(QString activeConnectionUni READ activeConnectionUni NOTIFY activeConnectionUniChanged)

    Q_PROPERTY(bool mobileDataEnabled READ mobileDataEnabled WRITE setMobileDataEnabled NOTIFY mobileDataEnabledChanged)
    Q_PROPERTY(bool mobileDataSupported READ mobileDataSupported NOTIFY mobileDataSupportedChanged)
    Q_PROPERTY(bool needsAPNAdded READ needsAPNAdded NOTIFY mobileDataEnabledChanged)

public:
    Modem(QObject *parent = nullptr);
    Modem(QObject *parent, ModemManager::ModemDevice::Ptr mmModem, ModemManager::Modem::Ptr m_mmInterface);

    ModemDetails *modemDetails() const;
    QString displayId() const; // splits uni and obtains the number suffix
    QString uni() const;
    QString activeConnectionUni() const;

    Q_INVOKABLE QCoro::Task<void> reset();

    bool mobileDataEnabled() const;
    void setMobileDataEnabled(bool enabled);
    bool mobileDataSupported() const;
    bool needsAPNAdded() const;

    bool isRoaming() const;
    QCoro::Task<void> setIsRoaming(bool roaming);
    bool hasSim() const;

    // connection profiles
    QList<ProfileSettings *> &profileList();
    void refreshProfiles();
    Q_INVOKABLE QCoro::Task<void> activateProfile(const QString &connectionUni);
    Q_INVOKABLE QCoro::Task<void> addProfile(QString name, QString apn, QString username, QString password, QString networkType);
    Q_INVOKABLE QCoro::Task<void> removeProfile(const QString &connectionUni);
    Q_INVOKABLE QCoro::Task<void> updateProfile(QString connectionUni, QString name, QString apn, QString username, QString password, QString networkType);
    Q_INVOKABLE void addDetectedProfileSettings(); // detect modem connection settings (ex. apn) and add a new connection

    QList<Sim *> sims();

    ModemManager::ModemDevice::Ptr mmModemDevice();
    NetworkManager::ModemDevice::Ptr nmModemDevice();
    ModemManager::Modem::Ptr mmModemInterface();

Q_SIGNALS:
    void modemDetailsChanged();
    void uniChanged();
    void displayIdChanged();
    void activeConnectionUniChanged();

    void nmModemChanged();

    void mobileDataEnabledChanged();
    void mobileDataSupportedChanged();
    void isRoamingChanged();
    void simsChanged();
    void hasSimChanged();
    void profileListChanged();

    void couldNotAutodetectSettings();

private:
    void findNetworkManagerDevice();

    QString nmDeviceStateStr(NetworkManager::Device::State state);

    ModemDetails *m_details;

    ModemManager::ModemDevice::Ptr m_mmModem;
    NetworkManager::ModemDevice::Ptr m_nmModem; // may be a nullptr if the nm modem hasn't been found yet
    ModemManager::Modem::Ptr m_mmInterface = nullptr;
    ModemManager::Modem3gpp::Ptr m_mm3gppDevice = nullptr; // this may be a nullptr if no sim is inserted

    QList<Sim *> m_sims;
    QList<ProfileSettings *> m_profileList;

    friend class ModemDetails;
};
