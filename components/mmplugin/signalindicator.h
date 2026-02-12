// SPDX-FileCopyrightText: 2021 Tobias Fella <fella@posteo.de>
// SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include <ModemManagerQt/Manager>
#include <ModemManagerQt/Modem3Gpp>

#include <NetworkManagerQt/Connection>
#include <NetworkManagerQt/ModemDevice>
#include <QCoroDBusPendingReply>

#include <QObject>
#include <qqmlregistration.h>

#include "profilesettings.h"

// We make the assumption that there is only one modem.
class SignalIndicator : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    Q_PROPERTY(int strength READ strength NOTIFY strengthChanged)
    Q_PROPERTY(QString name READ name NOTIFY nameChanged)
    Q_PROPERTY(bool modemAvailable READ modemAvailable NOTIFY modemAvailableChanged)
    Q_PROPERTY(bool simLocked READ simLocked NOTIFY simLockedChanged)
    Q_PROPERTY(bool simEmpty READ simEmpty NOTIFY simEmptyChanged)

    Q_PROPERTY(bool mobileDataSupported READ mobileDataSupported NOTIFY mobileDataSupportedChanged)
    Q_PROPERTY(bool mobileDataEnabled READ mobileDataEnabled WRITE setMobileDataEnabled NOTIFY mobileDataEnabledChanged)

    Q_PROPERTY(bool needsAPNAdded READ needsAPNAdded NOTIFY mobileDataEnabledChanged)
    Q_PROPERTY(QList<ProfileSettings *> profiles READ profileList NOTIFY profileListChanged)
    Q_PROPERTY(QString activeConnectionUni READ activeConnectionUni NOTIFY activeConnectionUniChanged)

public:
    SignalIndicator(QObject *parent = nullptr);

    int strength() const;
    QString name() const;
    bool modemAvailable() const;
    bool simLocked() const;
    bool simEmpty() const;
    bool mobileDataSupported() const;
    bool mobileDataEnabled() const;
    bool needsAPNAdded() const;
    QString activeConnectionUni() const;

    void setMobileDataEnabled(bool enabled);

    // connection profiles
    QList<ProfileSettings *> &profileList();
    void refreshProfiles();
    Q_INVOKABLE QCoro::Task<void> activateProfile(const QString &connectionUni);
    Q_INVOKABLE QCoro::Task<void> addProfile(const QString &name, const QString &apn, const QString &username, const QString &password, const QString &networkType);
    Q_INVOKABLE QCoro::Task<void> removeProfile(const QString &connectionUni);
    Q_INVOKABLE QCoro::Task<void> updateProfile(const QString &connectionUni,
                                   const QString &name,
                                   const QString &apn,
                                   const QString &username,
                                   const QString &password,
                                   const QString &networkType);

Q_SIGNALS:
    void strengthChanged();
    void nameChanged();
    void modemAvailableChanged();
    void simLockedChanged();
    void simEmptyChanged();
    void mobileDataSupportedChanged();
    void mobileDataEnabledChanged();
    void profileListChanged();
    void activeConnectionUniChanged();

private:
    NetworkManager::ModemDevice::Ptr m_nmModem;
    ModemManager::ModemDevice::Ptr m_modemDevice;
    ModemManager::Modem::Ptr m_modem;
    ModemManager::Modem3gpp::Ptr m_3gppModem;

    QList<ProfileSettings *> m_profileList;

    void updateModemManagerModem();
    void updateNetworkManagerModem();
};
