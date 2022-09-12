// SPDX-FileCopyrightText: 2021 Tobias Fella <fella@posteo.de>
// SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include <ModemManagerQt/Manager>
#include <ModemManagerQt/Modem3Gpp>

#include <NetworkManagerQt/Connection>
#include <NetworkManagerQt/ModemDevice>

#include <QObject>

// We make the assumption that there is only one modem.
class SignalIndicator : public QObject
{
    Q_OBJECT

    Q_PROPERTY(int strength READ strength NOTIFY strengthChanged)
    Q_PROPERTY(QString name READ name NOTIFY nameChanged)
    Q_PROPERTY(bool simLocked READ simLocked NOTIFY simLockedChanged)
    Q_PROPERTY(bool simEmpty READ simEmpty NOTIFY simEmptyChanged)
    Q_PROPERTY(bool available READ available NOTIFY availableChanged)
    Q_PROPERTY(bool mobileDataSupported READ mobileDataSupported NOTIFY mobileDataSupportedChanged)
    Q_PROPERTY(bool mobileDataEnabled READ mobileDataEnabled WRITE setMobileDataEnabled NOTIFY mobileDataEnabledChanged)
    Q_PROPERTY(bool needsAPNAdded READ needsAPNAdded NOTIFY mobileDataEnabledChanged)

public:
    SignalIndicator();

    int strength() const;
    QString name() const;
    bool simLocked() const;
    bool simEmpty() const;
    bool available() const;
    bool mobileDataSupported() const;
    bool mobileDataEnabled() const;
    bool needsAPNAdded() const;

    void setMobileDataEnabled(bool enabled);

Q_SIGNALS:
    void strengthChanged();
    void nameChanged();
    void simLockedChanged();
    void simEmptyChanged();
    void availableChanged();
    void mobileDataSupportedChanged();
    void mobileDataEnabledChanged();

private:
    NetworkManager::ModemDevice::Ptr m_nmModem;
    ModemManager::ModemDevice::Ptr m_modemDevice;
    ModemManager::Modem::Ptr m_modem;
    ModemManager::Modem3gpp::Ptr m_3gppModem;

    void updateModem();
};
