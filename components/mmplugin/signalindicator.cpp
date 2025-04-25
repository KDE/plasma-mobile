// SPDX-FileCopyrightText: 2021 Tobias Fella <fella@posteo.de>
// SPDX-FileCopyrightText: 2022-2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "signalindicator.h"

#include <NetworkManagerQt/GsmSetting>
#include <NetworkManagerQt/Manager>
#include <NetworkManagerQt/Settings>
#include <NetworkManagerQt/Utils>
#include <QDBusReply>

#include <KUser>

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
    // if wwan is globally disabled
    if (!NetworkManager::isWwanEnabled()) {
        return false;
    }

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
    // ensure that wwan is on
    if (enabled && !NetworkManager::isWwanEnabled()) {
        NetworkManager::setWwanEnabled(true);
    }

    if (!m_nmModem) {
        return;
    }

    if (enabled) {
        // enable mobile data...

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

    } else {
        // disable mobile data...

        // we do not call NetworkManager::setWwanEnabled(false), because it turns off cellular

        // turn off autoconnect
        m_nmModem->setAutoconnect(false);
        // we need to also set all connections to not autoconnect (#182)
        for (NetworkManager::Connection::Ptr con : m_nmModem->availableConnections()) {
            con->settings()->setAutoconnect(false);
            con->update(con->settings()->toMap());
        }

        // disconnect network
        m_nmModem->disconnectInterface();
    }
}

QString SignalIndicator::activeConnectionUni() const
{
    if (m_nmModem && m_nmModem->activeConnection() && m_nmModem->activeConnection()->connection()) {
        return m_nmModem->activeConnection()->connection()->uuid();
    }
    return QString();
}

QList<ProfileSettings *> &SignalIndicator::profileList()
{
    return m_profileList;
}

void SignalIndicator::refreshProfiles()
{
    m_profileList.clear();

    if (!m_nmModem) {
        Q_EMIT profileListChanged();
        qWarning() << "No NetworkManager modem found, cannot refresh profiles.";
        return;
    }

    for (auto connection : m_nmModem->availableConnections()) {
        for (auto setting : connection->settings()->settings()) {
            if (setting.dynamicCast<NetworkManager::GsmSetting>()) {
                m_profileList.append(new ProfileSettings(this, setting.dynamicCast<NetworkManager::GsmSetting>(), connection));
            }
        }
    }
    Q_EMIT profileListChanged();
}

QCoro::Task<void> SignalIndicator::activateProfile(const QString &connectionUni)
{
    if (!m_nmModem) {
        qWarning() << "Cannot activate profile since there is no NetworkManager modem";
        co_return;
    }

    qDebug() << QStringLiteral("Activating profile on modem") << m_nmModem->uni() << QStringLiteral("for connection") << connectionUni << ".";

    NetworkManager::Connection::Ptr con;

    // disable autoconnect for all other connections
    for (auto connection : m_nmModem->availableConnections()) {
        if (connection->uuid() == connectionUni) {
            connection->settings()->setAutoconnect(true);
            con = connection;
        } else {
            connection->settings()->setAutoconnect(false);
        }
    }

    if (!con) {
        qDebug() << QStringLiteral("Connection") << connectionUni << QStringLiteral("not found.");
        co_return;
    }

    // activate connection manually
    // despite the documentation saying otherwise, activateConnection seems to need the DBus path, not uuid of the connection
    QDBusReply<QDBusObjectPath> reply = co_await NetworkManager::activateConnection(con->path(), m_nmModem->uni(), {});
    if (!reply.isValid()) {
        qWarning() << QStringLiteral("Error activating connection:") << reply.error().message();
        co_return;
    }
}

QCoro::Task<void> SignalIndicator::addProfile(const QString &name, const QString &apn, const QString &username, const QString &password, const QString &networkType)
{
    if (!m_nmModem) {
        qWarning() << "Cannot add profile since there is no NetworkManager modem";
        co_return;
    }

    NetworkManager::ConnectionSettings::Ptr settings{new NetworkManager::ConnectionSettings(NetworkManager::ConnectionSettings::Gsm)};
    settings->setId(name);
    settings->setUuid(NetworkManager::ConnectionSettings::createNewUuid());
    settings->setAutoconnect(true);
    settings->addToPermissions(KUser().loginName(), QString());

    NetworkManager::GsmSetting::Ptr gsmSetting = settings->setting(NetworkManager::Setting::Gsm).dynamicCast<NetworkManager::GsmSetting>();
    gsmSetting->setApn(apn);
    gsmSetting->setUsername(username);
    gsmSetting->setPassword(password);
    gsmSetting->setPasswordFlags(password.isEmpty() ? NetworkManager::Setting::NotRequired : NetworkManager::Setting::AgentOwned);
    gsmSetting->setNetworkType(ProfileSettings::networkTypeFlag(networkType));

    gsmSetting->setInitialized(true);

    QDBusReply<QDBusObjectPath> reply = co_await NetworkManager::addAndActivateConnection(settings->toMap(), m_nmModem->uni(), {});
    if (!reply.isValid()) {
        qWarning() << "Error adding connection:" << reply.error().message();
    } else {
        qDebug() << "Successfully added a new connection" << name << "with APN" << apn << ".";
    }
}

QCoro::Task<void> SignalIndicator::removeProfile(const QString &connectionUni)
{
    NetworkManager::Connection::Ptr con = NetworkManager::findConnectionByUuid(connectionUni);
    if (!con) {
        qWarning() << "Could not find connection" << connectionUni << "to update!";
        co_return;
    }

    QDBusPendingReply reply = co_await con->remove();
    if (!reply.isValid()) {
        qWarning() << "Error removing connection" << reply.error().message();
    }
}

QCoro::Task<void> SignalIndicator::updateProfile(const QString &connectionUni,
                                                 const QString &name,
                                                 const QString &apn,
                                                 const QString &username,
                                                 const QString &password,
                                                 const QString &networkType)
{
    NetworkManager::Connection::Ptr con = NetworkManager::findConnectionByUuid(connectionUni);
    if (!con) {
        qWarning() << "Could not find connection" << connectionUni << "to update!";
        co_return;
    }

    NetworkManager::ConnectionSettings::Ptr conSettings = con->settings();
    if (!conSettings) {
        qWarning() << "Could not find connection settings for" << connectionUni << "to update!";
        co_return;
    }

    conSettings->setId(name);

    NetworkManager::GsmSetting::Ptr gsmSetting = conSettings->setting(NetworkManager::Setting::Gsm).dynamicCast<NetworkManager::GsmSetting>();
    gsmSetting->setApn(apn);
    gsmSetting->setUsername(username);
    gsmSetting->setPassword(password);
    gsmSetting->setPasswordFlags(password.isEmpty() ? NetworkManager::Setting::NotRequired : NetworkManager::Setting::AgentOwned);
    gsmSetting->setNetworkType(ProfileSettings::networkTypeFlag(networkType));

    gsmSetting->setInitialized(true);

    QDBusPendingReply reply = co_await con->update(conSettings->toMap());
    if (!reply.isValid()) {
        qWarning() << "Error updating connection settings for" << connectionUni << ":" << reply.error().message() << ".";
    } else {
        qDebug() << "Successfully updated connection settings" << connectionUni << ".";
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

            connect(m_nmModem.data(), &NetworkManager::ModemDevice::availableConnectionChanged, this, &SignalIndicator::refreshProfiles);
            connect(m_nmModem.data(), &NetworkManager::ModemDevice::activeConnectionChanged, this, [this]() -> void {
                refreshProfiles();
                Q_EMIT activeConnectionUniChanged();
            });

            refreshProfiles();
        }
    }

    Q_EMIT mobileDataSupportedChanged();
    Q_EMIT mobileDataEnabledChanged();
}
