/*
    SPDX-FileCopyrightText: 2021 Devin Lin <espidev@gmail.com>

    SPDX-License-Identifier: GPL-3.0-or-later
*/

#pragma once

#include "modem.h"

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

class Sim : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool enabled READ enabled NOTIFY enabledChanged)
    Q_PROPERTY(bool pinEnabled READ pinEnabled NOTIFY pinEnabledChanged) // if there is a PIN set on the SIM
    Q_PROPERTY(int unlockRetriesLeft READ unlockRetriesLeft NOTIFY unlockRetriesLeftChanged)
    Q_PROPERTY(bool locked READ locked NOTIFY lockedChanged) // if the SIM is currently locked (requires entering PIN)
    Q_PROPERTY(QString lockedReason READ lockedReason NOTIFY lockedReasonChanged)
    Q_PROPERTY(QString imsi READ imsi NOTIFY imsiChanged)
    Q_PROPERTY(QString eid READ eid NOTIFY eidChanged) // TODO (not in mm-qt)
    Q_PROPERTY(QString operatorIdentifier READ operatorIdentifier NOTIFY operatorIdentifierChanged)
    Q_PROPERTY(QString operatorName READ operatorName NOTIFY operatorNameChanged)
    Q_PROPERTY(QString simIdentifier READ simIdentifier NOTIFY simIdentifierChanged)
    Q_PROPERTY(QStringList emergencyNumbers READ emergencyNumbers NOTIFY emergencyNumbersChanged)
    Q_PROPERTY(QString uni READ uni NOTIFY uniChanged)
    Q_PROPERTY(QString displayId READ displayId NOTIFY displayIdChanged)
    Q_PROPERTY(Modem *modem READ modem NOTIFY modemChanged)

public:
    Sim(QObject *parent = nullptr,
        Modem *modem = nullptr,
        ModemManager::Sim::Ptr mmSim = ModemManager::Sim::Ptr{nullptr},
        ModemManager::Modem::Ptr mmModem = ModemManager::Modem::Ptr{nullptr},
        ModemManager::Modem3gpp::Ptr mmModem3gpp = ModemManager::Modem3gpp::Ptr{nullptr});

    bool enabled();
    bool pinEnabled();
    int unlockRetriesLeft();
    bool locked();
    QString lockedReason();
    QString imsi();
    QString eid(); // TODO add in mm-qt
    QString operatorIdentifier();
    QString operatorName();
    QString simIdentifier();
    QStringList emergencyNumbers(); // TODO add in mm-qt
    QString uni();
    QString displayId();
    Modem *modem();

    Q_INVOKABLE void togglePinEnabled(const QString &pin);
    Q_INVOKABLE void changePin(const QString &oldPin, const QString &newPin);
    Q_INVOKABLE void sendPin(const QString &pin);
    Q_INVOKABLE void sendPuk(const QString &pin, const QString &puk);

Q_SIGNALS:
    void enabledChanged();
    void pinEnabledChanged();
    void unlockRetriesLeftChanged();
    void lockedChanged();
    void lockedReasonChanged();
    void imsiChanged();
    void eidChanged();
    void operatorIdentifierChanged();
    void operatorNameChanged();
    void simIdentifierChanged();
    void emergencyNumbersChanged();
    void uniChanged();
    void displayIdChanged();
    void modemChanged();

private:
    Modem *m_modem;
    ModemManager::Sim::Ptr m_mmSim;
    ModemManager::Modem::Ptr m_mmModem;
    ModemManager::Modem3gpp::Ptr m_mmModem3gpp; // this may be a nullptr if no sim is inserted
};
