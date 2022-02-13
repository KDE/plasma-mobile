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
    if (!m_nmModem) {
        return false;
    }

    return m_nmModem->state() == NetworkManager::Device::Activated || m_nmModem->autoconnect();
}

void SignalIndicator::setMobileDataEnabled(bool enabled)
{
    if (!m_nmModem) {
        return;
    }

    if (!enabled) {
        m_nmModem->setAutoconnect(false);

        // before disconnecting, we ensure the current active connection is set to autoconnect
        for (NetworkManager::Connection::Ptr con : m_nmModem->availableConnections()) {
            if (con->uuid() == m_nmModem->activeConnection()->uuid()) {
                con->settings()->setAutoconnect(true);
            } else {
                con->settings()->setAutoconnect(false);
            }
        }

        m_nmModem->disconnectInterface().waitForFinished();
    } else {
        m_nmModem->setAutoconnect(true);

        // activate the connection that is set to autoconnect
        for (NetworkManager::Connection::Ptr con : m_nmModem->availableConnections()) {
            if (con->settings()->autoconnect()) {
                NetworkManager::activateConnection(con->path(), m_nmModem->uni(), "");
                break;
            }
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

    connect(m_modem.get(), &ModemManager::Modem::signalQualityChanged, this, &SignalIndicator::strengthChanged);
    connect(m_3gppModem.get(), &ModemManager::Modem3gpp::operatorNameChanged, this, &SignalIndicator::nameChanged);
    connect(m_modem.get(), &ModemManager::Modem::unlockRequiredChanged, this, &SignalIndicator::simLockedChanged);

    Q_EMIT mobileDataSupportedChanged();
    Q_EMIT nameChanged();
    Q_EMIT availableChanged();
}
