// SPDX-FileCopyrightText: 2021 Tobias Fella <fella@posteo.de>
// SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include <NetworkManagerQt/GsmSetting>
#include <NetworkManagerQt/Manager>
#include <NetworkManagerQt/Settings>
#include <NetworkManagerQt/Utils>

#include "signalindicator.h"

SignalIndicator::SignalIndicator(QObject *parent)
    : QObject{parent}
    , m_nmModem{nullptr}
    , m_modemDevice{nullptr}
    , m_modem{nullptr}
    , m_3gppModem{nullptr}
{
    connect(ModemManager::notifier(), &ModemManager::Notifier::modemAdded, this, &SignalIndicator::updateModemManagerModem);
    connect(ModemManager::notifier(), &ModemManager::Notifier::modemRemoved, this, &SignalIndicator::updateModemManagerModem);

    connect(NetworkManager::settingsNotifier(), &NetworkManager::SettingsNotifier::connectionAdded, this, &SignalIndicator::mobileDataEnabledChanged);
    connect(NetworkManager::settingsNotifier(), &NetworkManager::SettingsNotifier::connectionRemoved, this, &SignalIndicator::mobileDataEnabledChanged);
    connect(NetworkManager::notifier(), &NetworkManager::Notifier::activeConnectionAdded, this, &SignalIndicator::mobileDataEnabledChanged);
    connect(NetworkManager::notifier(), &NetworkManager::Notifier::activeConnectionRemoved, this, &SignalIndicator::mobileDataEnabledChanged);
    connect(NetworkManager::notifier(), &NetworkManager::Notifier::deviceAdded, this, &SignalIndicator::updateNetworkManagerModem);
    connect(NetworkManager::notifier(), &NetworkManager::Notifier::deviceRemoved, this, &SignalIndicator::updateNetworkManagerModem);

    updateModemManagerModem();
}

int SignalIndicator::strength() const
{
    if (!m_modem) {
        return 0;
    }
    return m_modem->signalQuality().signal;
}

QString SignalIndicator::name() const
{
    return m_3gppModem ? m_3gppModem->operatorName() : QString();
}

bool SignalIndicator::modemAvailable() const
{
    return !m_modem.isNull();
}

bool SignalIndicator::simLocked() const
{
    if (!m_modem) {
        return false;
    }
    return m_modem->unlockRequired() == MM_MODEM_LOCK_SIM_PIN;
}

bool SignalIndicator::simEmpty() const
{
    return !m_modemDevice || !m_modemDevice->sim() || (m_modemDevice->sim()->uni() == QStringLiteral("/"));
}

bool SignalIndicator::mobileDataSupported() const
{
    return m_nmModem && !simEmpty();
}

bool SignalIndicator::mobileDataEnabled() const
{
    // no modem -> no mobile data -> report disabled
    if (!m_nmModem) {
        return false;
    }

    // mobile data already activated -> report enabled
    if (m_nmModem->state() == NetworkManager::Device::Activated) {
        return true;
    }

    // autoconnect disabled on the entire modem -> report disabled
    if (!m_nmModem->autoconnect()) {
        return false;
    }

    // at least one connection set to autoconnect -> report enabled
    for (NetworkManager::Connection::Ptr con : m_nmModem->availableConnections()) {
        if (con->settings()->autoconnect()) {
            return true;
        }
    }

    // modem, but no connection, set to autoconnect -> report disabled (#182)
    return false;
}

bool SignalIndicator::needsAPNAdded() const
{
    return m_nmModem && mobileDataSupported() && m_nmModem->availableConnections().count() == 0;
}

void SignalIndicator::setMobileDataEnabled(bool enabled)
{
    if (!m_nmModem) {
        return;
    }
    if (!enabled) {
        m_nmModem->setAutoconnect(false);
        // we need to also set all connections to not autoconnect (#182)
        for (NetworkManager::Connection::Ptr con : m_nmModem->availableConnections()) {
            con->settings()->setAutoconnect(false);
            con->update(con->settings()->toMap());
        }
        m_nmModem->disconnectInterface();
    } else {
        m_nmModem->setAutoconnect(true);
        // activate the connection that was last used
        QDateTime latestTimestamp;
        NetworkManager::Connection::Ptr latestCon;
        for (NetworkManager::Connection::Ptr con : m_nmModem->availableConnections()) {
            QDateTime timestamp = con->settings()->timestamp();
            // if con was not used yet, skip it, otherwise:
            // if we have no latestTimestamp yet, con is the latest
            // otherwise, compare the timestamps
            // in case of a tie, use the first connection that was found
            if (!timestamp.isNull() && (latestTimestamp.isNull() || timestamp > latestTimestamp)) {
                latestTimestamp = timestamp;
                latestCon = con;
            }
        }
        // if we found the last used connection
        if (!latestCon.isNull()) {
            // set it to autoconnect and connect it immediately
            latestCon->settings()->setAutoconnect(true);
            latestCon->update(latestCon->settings()->toMap());
            NetworkManager::activateConnection(latestCon->path(), m_nmModem->uni(), "");
        }
    }
}

void SignalIndicator::updateModemManagerModem()
{
    m_modemDevice = nullptr;
    m_modem = nullptr;
    m_3gppModem = nullptr;

    if (ModemManager::modemDevices().isEmpty()) {
        qWarning() << "No modems available";
        return;
    }

    // TODO: we assume that there is a single modem for the time being
    m_modemDevice = ModemManager::modemDevices()[0];
    m_modem = m_modemDevice->modemInterface();
    m_3gppModem = m_modemDevice->interface(ModemManager::ModemDevice::GsmInterface).objectCast<ModemManager::Modem3gpp>();

    connect(m_modemDevice->sim().get(), &ModemManager::Sim::simIdentifierChanged, this, &SignalIndicator::simEmptyChanged);

    if (m_modem) {
        connect(m_modem.get(), &ModemManager::Modem::signalQualityChanged, this, &SignalIndicator::strengthChanged);
        connect(m_modem.get(), &ModemManager::Modem::unlockRequiredChanged, this, &SignalIndicator::simLockedChanged);
    }
    if (m_3gppModem) {
        connect(m_3gppModem.get(), &ModemManager::Modem3gpp::operatorNameChanged, this, &SignalIndicator::nameChanged);
    }

    updateNetworkManagerModem();

    Q_EMIT nameChanged();
    Q_EMIT strengthChanged();
    Q_EMIT modemAvailableChanged();
}

void SignalIndicator::updateNetworkManagerModem()
{
    m_nmModem = nullptr;
    if (!m_modemDevice) {
        return;
    }

    // find networkmanager modem
    for (NetworkManager::Device::Ptr nmDevice : NetworkManager::networkInterfaces()) {
        if (nmDevice->udi() == m_modemDevice->uni()) {
            m_nmModem = nmDevice.objectCast<NetworkManager::ModemDevice>();

            connect(m_nmModem.get(), &NetworkManager::Device::autoconnectChanged, this, &SignalIndicator::mobileDataEnabledChanged);
            connect(m_nmModem.get(), &NetworkManager::Device::stateChanged, this, &SignalIndicator::mobileDataEnabledChanged);
            connect(m_nmModem.get(), &NetworkManager::Device::availableConnectionAppeared, this, &SignalIndicator::mobileDataEnabledChanged);
            connect(m_nmModem.get(), &NetworkManager::Device::availableConnectionDisappeared, this, &SignalIndicator::mobileDataEnabledChanged);
        }
    }

    Q_EMIT mobileDataSupportedChanged();
    Q_EMIT mobileDataEnabledChanged();
}
