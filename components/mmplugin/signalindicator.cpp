// SPDX-FileCopyrightText: 2021 Tobias Fella <fella@posteo.de>
// SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include <NetworkManagerQt/GsmSetting>
#include <NetworkManagerQt/Manager>

#include "signalindicator.h"

SignalIndicator::SignalIndicator()
{
    connect(ModemManager::notifier(), &ModemManager::Notifier::modemAdded, this, &SignalIndicator::updateModem);
    connect(ModemManager::notifier(), &ModemManager::Notifier::modemRemoved, this, &SignalIndicator::updateModem);
    updateModem();
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

bool SignalIndicator::simLocked() const
{
    if (!m_modem) {
        return false;
    }
    return m_modem->unlockRequired() == MM_MODEM_LOCK_SIM_PIN;
}

bool SignalIndicator::available() const
{
    return !ModemManager::modemDevices().isEmpty();
}

bool SignalIndicator::mobileDataSupported() const
{
    return m_nmModem && m_modemDevice->sim();
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
    return m_nmModem && m_nmModem->availableConnections().count() == 0;
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
        m_nmModem->disconnectInterface().waitForFinished();
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

void SignalIndicator::updateModem()
{
    if (!available()) {
        qWarning() << "No modems available";
        return;
    }

    // we assume that there is a single modem
    m_modemDevice = ModemManager::modemDevices()[0];
    m_modem = m_modemDevice->modemInterface();
    m_3gppModem = m_modemDevice->interface(ModemManager::ModemDevice::GsmInterface).objectCast<ModemManager::Modem3gpp>();

    // find networkmanager modem
    for (NetworkManager::Device::Ptr nmDevice : NetworkManager::networkInterfaces()) {
        if (nmDevice->udi() == m_modemDevice->uni()) {
            m_nmModem = nmDevice.objectCast<NetworkManager::ModemDevice>();

            connect(m_nmModem.get(), &NetworkManager::Device::autoconnectChanged, this, [this]() {
                Q_EMIT mobileDataEnabledChanged();
            });
            connect(m_nmModem.get(), &NetworkManager::Device::stateChanged, this, [this](auto, auto, auto) {
                Q_EMIT mobileDataEnabledChanged();
            });
        }
    }

    if (m_modem) {
        connect(m_modem.get(), &ModemManager::Modem::signalQualityChanged, this, &SignalIndicator::strengthChanged);
        connect(m_modem.get(), &ModemManager::Modem::unlockRequiredChanged, this, &SignalIndicator::simLockedChanged);
    }
    if (m_3gppModem) {
        connect(m_3gppModem.get(), &ModemManager::Modem3gpp::operatorNameChanged, this, &SignalIndicator::nameChanged);
    }

    Q_EMIT mobileDataSupportedChanged();
    Q_EMIT nameChanged();
    Q_EMIT availableChanged();
}
