// SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include "modem.h"
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

class Modem;
class AvailableNetwork;

class ModemDetails : public QObject
{
    Q_OBJECT
    // modemmanager device
    Q_PROPERTY(QStringList accessTechnologies READ accessTechnologies NOTIFY accessTechnologiesChanged) // currently used tech
    Q_PROPERTY(QString device READ device NOTIFY deviceChanged)
    Q_PROPERTY(QString deviceIdentifier READ deviceIdentifier NOTIFY deviceIdentifierChanged)
    Q_PROPERTY(QStringList drivers READ drivers NOTIFY driversChanged)
    Q_PROPERTY(QString equipmentIdentifier READ equipmentIdentifier NOTIFY equipmentIdentifierChanged)
    // TODO add bands
    Q_PROPERTY(bool isEnabled READ isEnabled NOTIFY isEnabledChanged)
    Q_PROPERTY(QString manufacturer READ manufacturer NOTIFY manufacturerChanged)
    Q_PROPERTY(QString model READ model NOTIFY modelChanged)
    Q_PROPERTY(QStringList ownNumbers READ ownNumbers NOTIFY ownNumbersChanged)
    Q_PROPERTY(QString plugin READ plugin NOTIFY pluginChanged)
    Q_PROPERTY(QString powerState READ powerState NOTIFY powerStateChanged)
    Q_PROPERTY(QString revision READ revision NOTIFY revisionChanged)
    Q_PROPERTY(uint signalQuality READ signalQuality NOTIFY signalQualityChanged)
    Q_PROPERTY(QString simPath READ simPath NOTIFY simPathChanged)
    Q_PROPERTY(QString state READ state NOTIFY stateChanged)
    Q_PROPERTY(QString stateFailedReason READ stateFailedReason NOTIFY stateFailedReasonChanged)

    // modemmanager 3gpp device
    Q_PROPERTY(QString operatorCode READ operatorCode NOTIFY operatorCodeChanged)
    Q_PROPERTY(QString operatorName READ operatorName NOTIFY operatorNameChanged)
    Q_PROPERTY(QString registrationState READ registrationState NOTIFY registrationStateChanged)
    Q_PROPERTY(QList<AvailableNetwork *> networks READ networks NOTIFY networksChanged)
    Q_PROPERTY(bool isScanningNetworks READ isScanningNetworks NOTIFY isScanningNetworksChanged)

    // networkmanager device
    Q_PROPERTY(QString firmwareVersion READ firmwareVersion NOTIFY firmwareVersionChanged)
    Q_PROPERTY(QString interfaceName READ interfaceName NOTIFY interfaceNameChanged)
    Q_PROPERTY(QString metered READ metered NOTIFY meteredChanged)

public:
    ModemDetails(QObject *parent = nullptr, Modem *modem = nullptr);
    ModemDetails &operator=(ModemDetails &&other);
    void swap(ModemDetails &other);

    QStringList accessTechnologies();
    QString device();
    QString deviceIdentifier();
    QStringList drivers();
    QString equipmentIdentifier();
    bool isEnabled();
    QString manufacturer();
    uint maxActiveBearers();
    uint maxBearers();
    QString model();
    QStringList ownNumbers();
    QString plugin();
    QString powerState();
    QString revision();
    uint signalQuality();
    QString simPath();
    QString state();
    QString stateFailedReason();

    QString operatorCode();
    QString operatorName();
    QString registrationState();

    Q_INVOKABLE void scanNetworks();
    QList<AvailableNetwork *> networks();
    bool isScanningNetworks();
    void scanNetworksFinished(QDBusPendingCallWatcher *call);

    QString firmwareVersion();
    QString interfaceName();
    QString metered();

Q_SIGNALS:
    void accessTechnologiesChanged();
    void deviceChanged();
    void deviceIdentifierChanged();
    void driversChanged();
    void equipmentIdentifierChanged();
    void isEnabledChanged();
    void manufacturerChanged();
    void modelChanged();
    void ownNumbersChanged();
    void pluginChanged();
    void powerStateChanged();
    void revisionChanged();
    void signalQualityChanged();
    void simPathChanged();
    void stateChanged();
    void stateFailedReasonChanged();
    void supportedCapabilitiesChanged();

    void operatorCodeChanged();
    void operatorNameChanged();
    void registrationStateChanged();
    void networksChanged();
    void isScanningNetworksChanged();

    void firmwareVersionChanged();
    void interfaceNameChanged();
    void meteredChanged();

private:
    void updateNMSignals();

    Modem *m_modem;

    QDBusPendingCallWatcher *m_scanNetworkWatcher;
    bool m_isScanningNetworks;
    QList<AvailableNetwork *> m_cachedScannedNetworks;
};

class AvailableNetwork : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool isCurrentlyUsed READ isCurrentlyUsed NOTIFY isCurrentlyUsedChanged)
    Q_PROPERTY(QString operatorLong READ operatorLong NOTIFY operatorLongChanged)
    Q_PROPERTY(QString operatorShort READ operatorShort NOTIFY operatorShortChanged)
    Q_PROPERTY(QString operatorCode READ operatorCode NOTIFY operatorCodeChanged)
    Q_PROPERTY(QString accessTechnology READ accessTechnology NOTIFY accessTechnologyChanged)

public:
    AvailableNetwork(QObject *parent = nullptr,
                     ModemManager::Modem3gpp::Ptr mm3gppDevice = nullptr,
                     bool isCurrentlyUsed = false,
                     QString operatorLong = "",
                     QString operatorShort = "",
                     QString operatorCode = "",
                     MMModemAccessTechnology accessTechnology = MM_MODEM_ACCESS_TECHNOLOGY_UNKNOWN);

    bool isCurrentlyUsed();
    QString operatorLong();
    QString operatorShort();
    QString operatorCode();
    QString accessTechnology();

    Q_INVOKABLE void registerToNetwork();

Q_SIGNALS:
    void isCurrentlyUsedChanged();
    void operatorLongChanged();
    void operatorShortChanged();
    void operatorCodeChanged();
    void accessTechnologyChanged();

private:
    bool m_isCurrentlyUsed;
    QString m_operatorLong;
    QString m_operatorShort;
    QString m_operatorCode;
    QString m_accessTechnology;

    ModemManager::Modem3gpp::Ptr m_mm3gppDevice; // this may be a nullptr if no sim is inserted
};
