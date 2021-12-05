// SPDX-FileCopyrightText: 2021 Tobias Fella <fella@posteo.de>
// SPDX-License-Identifier: GPL-2.0-or-later

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
    return !(m_modem->unlockRequired() == MM_MODEM_LOCK_NONE || m_modem->unlockRequired() == MM_MODEM_LOCK_SIM_PIN2);
}

bool SignalIndicator::available() const
{
    return !ModemManager::modemDevices().isEmpty();
}

void SignalIndicator::updateModem()
{
    if (!available()) {
        qWarning() << "No modems available";
        return;
    }
    m_modem = ModemManager::modemDevices()[0]->modemInterface();
    m_3gppModem = ModemManager::modemDevices()[0]->interface(ModemManager::ModemDevice::GsmInterface).objectCast<ModemManager::Modem3gpp>();
    Q_EMIT nameChanged();
    connect(m_modem.get(), &ModemManager::Modem::signalQualityChanged, this, &SignalIndicator::strengthChanged);
    connect(m_3gppModem.get(), &ModemManager::Modem3gpp::operatorNameChanged, this, &SignalIndicator::nameChanged);
    connect(m_modem.get(), &ModemManager::Modem::unlockRequiredChanged, this, &SignalIndicator::simLockedChanged);
    Q_EMIT availableChanged();
}
