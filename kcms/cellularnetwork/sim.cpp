// SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "sim.h"

#include <KLocalizedString>

#include <QDBusReply>

Sim::Sim(QObject *parent, Modem *modem, ModemManager::Sim::Ptr mmSim, ModemManager::Modem::Ptr mmModem, ModemManager::Modem3gpp::Ptr mmModem3gpp)
    : QObject{parent}
    , m_modem{modem}
    , m_mmSim{mmSim}
    , m_mmModem{mmModem}
    , m_mmModem3gpp{mmModem3gpp}
{
    if (m_mmSim) {
        connect(m_mmSim.data(), &ModemManager::Sim::imsiChanged, this, [this]() -> void {
            Q_EMIT imsiChanged();
        });
        connect(m_mmSim.data(), &ModemManager::Sim::operatorIdentifierChanged, this, [this]() -> void {
            Q_EMIT operatorIdentifierChanged();
        });
        connect(m_mmSim.data(), &ModemManager::Sim::operatorNameChanged, this, [this]() -> void {
            Q_EMIT operatorNameChanged();
        });
        connect(m_mmSim.data(), &ModemManager::Sim::simIdentifierChanged, this, [this]() -> void {
            Q_EMIT simIdentifierChanged();
        });
    }

    if (m_mmModem) {
        connect(m_mmModem.data(), &ModemManager::Modem::unlockRequiredChanged, this, [this]() -> void {
            Q_EMIT lockedChanged();
            Q_EMIT lockedReasonChanged();
        });
    }

    if (m_mmModem3gpp) {
        connect(m_mmModem3gpp.data(), &ModemManager::Modem3gpp::enabledFacilityLocksChanged, this, [this]() -> void {
            Q_EMIT pinEnabledChanged();
        });
    }
}

bool Sim::enabled()
{
    return uni() != QStringLiteral("/");
}

bool Sim::pinEnabled()
{
    return m_mmModem3gpp && (m_mmModem3gpp->enabledFacilityLocks() & MM_MODEM_3GPP_FACILITY_SIM);
}

int Sim::unlockRetriesLeft()
{
    return m_mmModem && m_mmModem->unlockRetries()[MM_MODEM_LOCK_SIM_PIN];
}

bool Sim::locked()
{
    return m_mmModem && m_mmModem->unlockRequired() == MM_MODEM_LOCK_SIM_PIN;
}

QString Sim::lockedReason()
{
    if (!m_mmModem) {
        return {};
    }

    switch (m_mmModem->unlockRequired()) {
    case MM_MODEM_LOCK_UNKNOWN:
        return i18n("Lock reason unknown.");
    case MM_MODEM_LOCK_NONE:
        return i18n("Modem is unlocked.");
    case MM_MODEM_LOCK_SIM_PIN:
        return i18n("SIM requires the PIN code.");
    case MM_MODEM_LOCK_SIM_PIN2:
        return i18n("SIM requires the PIN2 code.");
    case MM_MODEM_LOCK_SIM_PUK:
        return i18n("SIM requires the PUK code.");
    case MM_MODEM_LOCK_SIM_PUK2:
        return i18n("SIM requires the PUK2 code.");
    case MM_MODEM_LOCK_PH_SP_PIN:
        return i18n("Modem requires the service provider PIN code.");
    case MM_MODEM_LOCK_PH_SP_PUK:
        return i18n("Modem requires the service provider PUK code.");
    case MM_MODEM_LOCK_PH_NET_PIN:
        return i18n("Modem requires the network PIN code.");
    case MM_MODEM_LOCK_PH_NET_PUK:
        return i18n("Modem requires the network PUK code.");
    case MM_MODEM_LOCK_PH_SIM_PIN:
        return i18n("Modem requires the PIN code.");
    case MM_MODEM_LOCK_PH_CORP_PIN:
        return i18n("Modem requires the corporate PIN code.");
    case MM_MODEM_LOCK_PH_CORP_PUK:
        return i18n("Modem requires the corporate PUK code.");
    case MM_MODEM_LOCK_PH_FSIM_PIN:
        return i18n("Modem requires the PH-FSIM PIN code.");
    case MM_MODEM_LOCK_PH_FSIM_PUK:
        return i18n("Modem requires the PH-FSIM PUK code.");
    case MM_MODEM_LOCK_PH_NETSUB_PIN:
        return i18n("Modem requires the network subset PIN code.");
    case MM_MODEM_LOCK_PH_NETSUB_PUK:
        return i18n("Modem requires the network subset PUK code.");
    }
    return {};
}

QString Sim::imsi()
{
    return m_mmSim ? m_mmSim->imsi() : QString{};
}

QString Sim::eid()
{
    return {}; // TODO add in mm-qt
}

QString Sim::operatorIdentifier()
{
    return m_mmSim ? m_mmSim->operatorIdentifier() : QString{};
}

QString Sim::operatorName()
{
    return m_mmSim ? m_mmSim->operatorName() : QString{};
}

QString Sim::simIdentifier()
{
    return m_mmSim ? m_mmSim->simIdentifier() : QString{};
}

QStringList Sim::emergencyNumbers()
{
    return {}; // TODO add in mm-qt
}

QString Sim::uni()
{
    return m_mmSim ? m_mmSim->uni() : QString{};
}

QString Sim::displayId()
{
    // in the form /org/freedesktop/ModemManager1/Sim/0
    QStringList uniSplit = uni().split(QStringLiteral("/"));
    return (uniSplit.count() == 0 || uni() == "/") ? i18n("(empty)") : QString(uniSplit[uniSplit.size() - 1]);
}

Modem *Sim::modem()
{
    return m_modem;
}

QCoro::Task<void> Sim::togglePinEnabled(const QString &pin)
{
    bool isPinEnabled = pinEnabled();
    QDBusReply<void> reply = co_await m_mmSim->enablePin(pin, !isPinEnabled);
    if (!reply.isValid()) {
        qWarning() << QStringLiteral("Error toggling SIM lock to") << isPinEnabled << QStringLiteral(":") << reply.error().message();
        CellularNetworkSettings::instance()->addMessage(InlineMessage::Error, i18n("Error toggling SIM lock: %1", reply.error().message()));
    }
}

QCoro::Task<void> Sim::changePin(const QString &oldPin, const QString &newPin)
{
    QDBusReply<void> reply = co_await m_mmSim->changePin(oldPin, newPin);
    if (!reply.isValid()) {
        qWarning() << QStringLiteral("Error changing the PIN:") << reply.error().message();
        CellularNetworkSettings::instance()->addMessage(InlineMessage::Error, i18n("Error changing the PIN: %1", reply.error().message()));
    }
}

QCoro::Task<void> Sim::sendPin(const QString &pin)
{
    if (!m_mmModem || !m_mmSim || m_mmModem->unlockRequired() == MM_MODEM_LOCK_NONE) {
        co_return;
    }

    QDBusReply<void> reply = co_await m_mmSim->sendPin(pin);
    if (!reply.isValid()) {
        qWarning() << QStringLiteral("Error sending the PIN:") << reply.error().message();
        CellularNetworkSettings::instance()->addMessage(InlineMessage::Error, i18n("Error sending the PIN: %1", reply.error().message()));
    }
}

QCoro::Task<void> Sim::sendPuk(const QString &pin, const QString &puk)
{
    if (!m_mmModem || !m_mmSim || m_mmModem->unlockRequired() != MM_MODEM_LOCK_NONE) {
        co_return;
    }

    QDBusReply<void> reply = co_await m_mmSim->sendPuk(pin, puk);
    if (!reply.isValid()) {
        qWarning() << QStringLiteral("Error sending the PUK:") << reply.error().message();
        CellularNetworkSettings::instance()->addMessage(InlineMessage::Error, i18n("Error sending the PUK: %1", reply.error().message()));
    }
}
