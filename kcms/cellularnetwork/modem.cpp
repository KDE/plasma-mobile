// SPDX-FileCopyrightText: 2021-2022 Devin Lin <espidev@gmail.com>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "modem.h"

#include <utility>

#include <KLocalizedString>
#include <KUser>
#include <QDBusReply>

#include <QCoroDBusPendingReply>

Modem::Modem(QObject *parent)
    : QObject{parent}
{
}

Modem::Modem(QObject *parent, ModemManager::ModemDevice::Ptr mmModem, ModemManager::Modem::Ptr mmInterface)
    : QObject{parent}
    , m_mmModem{mmModem}
    , m_nmModem{nullptr}
    , m_mmInterface{mmInterface}
{
    // TODO multi-sim support
    m_sims = {new Sim{this, this, m_mmModem->sim(), m_mmInterface, m_mm3gppDevice}};

    connect(m_mmModem.data(), &ModemManager::ModemDevice::simAdded, this, &Modem::simsChanged);
    connect(m_mmModem.data(), &ModemManager::ModemDevice::simAdded, this, &Modem::hasSimChanged);
    connect(m_mmModem.data(), &ModemManager::ModemDevice::simRemoved, this, &Modem::simsChanged);
    connect(m_mmModem.data(), &ModemManager::ModemDevice::simRemoved, this, &Modem::hasSimChanged);

    if (m_mmModem->sim()) {
        connect(m_mmModem->sim().get(), &ModemManager::Sim::simIdentifierChanged, this, &Modem::hasSimChanged);
    }

    connect(NetworkManager::settingsNotifier(), &NetworkManager::SettingsNotifier::connectionAdded, this, &Modem::mobileDataEnabledChanged);
    connect(NetworkManager::settingsNotifier(), &NetworkManager::SettingsNotifier::connectionRemoved, this, &Modem::mobileDataEnabledChanged);
    connect(NetworkManager::notifier(), &NetworkManager::Notifier::activeConnectionAdded, this, &Modem::mobileDataEnabledChanged);
    connect(NetworkManager::notifier(), &NetworkManager::Notifier::activeConnectionRemoved, this, &Modem::mobileDataEnabledChanged);
    connect(NetworkManager::notifier(), &NetworkManager::Notifier::deviceAdded, this, &Modem::findNetworkManagerDevice);
    connect(NetworkManager::notifier(), &NetworkManager::Notifier::deviceRemoved, this, &Modem::findNetworkManagerDevice);

    // this is guaranteed to be a GSM modem
    m_mm3gppDevice = m_mmModem->interface(ModemManager::ModemDevice::GsmInterface).objectCast<ModemManager::Modem3gpp>();

    // if no sim is inserted, m_mm3gppDevice is nullptr
    if (m_mm3gppDevice) {
        m_mm3gppDevice->setTimeout(60000); // scanning networks likely takes longer than the default timeout
    }

    // find networkmanager modem, if it exists
    findNetworkManagerDevice();

    // we need to initialize it after m_mm3gppDevice has been set
    m_details = new ModemDetails(this, this);
}

void Modem::findNetworkManagerDevice()
{
    m_nmModem = nullptr;

    // find networkmanager modem device
    for (NetworkManager::Device::Ptr nmDevice : NetworkManager::networkInterfaces()) {
        if (nmDevice->udi() == m_mmModem->uni()) {
            m_nmModem = nmDevice.objectCast<NetworkManager::ModemDevice>();
        }
    }

    if (m_nmModem) {
        connect(m_nmModem.data(), &NetworkManager::Device::autoconnectChanged, this, &Modem::mobileDataEnabledChanged);
        connect(m_nmModem.data(), &NetworkManager::Device::stateChanged, this, &Modem::mobileDataEnabledChanged);
        connect(m_nmModem.data(), &NetworkManager::Device::availableConnectionAppeared, this, &Modem::mobileDataEnabledChanged);
        connect(m_nmModem.data(), &NetworkManager::Device::availableConnectionDisappeared, this, &Modem::mobileDataEnabledChanged);

        connect(m_nmModem.data(), &NetworkManager::ModemDevice::availableConnectionChanged, this, [this]() -> void {
            refreshProfiles();
        });
        connect(m_nmModem.data(), &NetworkManager::ModemDevice::activeConnectionChanged, this, [this]() -> void {
            refreshProfiles();
            Q_EMIT activeConnectionUniChanged();
        });
        connect(m_nmModem.data(), &NetworkManager::ModemDevice::stateChanged, this, [this](auto newstate, auto oldstate, auto reason) -> void {
            qDebug() << QStringLiteral("Modem") << m_nmModem->uni() << QStringLiteral("changed state:") << nmDeviceStateStr(oldstate) << QStringLiteral("->")
                     << nmDeviceStateStr(newstate) << QStringLiteral("due to:") << reason;
        });

        // add connection profiles
        refreshProfiles();
    }

    Q_EMIT nmModemChanged();
    Q_EMIT mobileDataEnabledChanged();
    Q_EMIT mobileDataSupportedChanged();
}

ModemDetails *Modem::modemDetails() const
{
    return m_details;
}

QString Modem::displayId() const
{
    // in the form /org/freedesktop/ModemManager1/Modem/0
    QStringList uniSplit = uni().split("/");
    return uniSplit.count() == 0 ? QStringLiteral("(empty)") : QString(uniSplit[uniSplit.size() - 1]);
}

QString Modem::uni() const
{
    return m_mmInterface->uni();
}

QString Modem::activeConnectionUni() const
{
    if (m_nmModem && m_nmModem->activeConnection() && m_nmModem->activeConnection()->connection()) {
        return m_nmModem->activeConnection()->connection()->uuid();
    }
    return QString();
}

QCoro::Task<void> Modem::reset()
{
    qDebug() << QStringLiteral("Resetting the modem...");

    QDBusReply<void> reply = co_await m_mmInterface->reset();

    if (!reply.isValid()) {
        qDebug() << QStringLiteral("Error resetting the modem:") << reply.error().message();
        CellularNetworkSettings::instance()->addMessage(InlineMessage::Error, i18n("Error resetting the modem: %1", reply.error().message()));
    }
}

bool Modem::mobileDataSupported() const
{
    return m_nmModem && hasSim();
}

bool Modem::needsAPNAdded() const
{
    return m_nmModem && mobileDataSupported() && m_nmModem->availableConnections().count() == 0;
}

bool Modem::mobileDataEnabled() const
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

    // modem, but no connection, set to autoconnect -> report disabled
    return false;
}

void Modem::setMobileDataEnabled(bool enabled)
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

bool Modem::isRoaming() const
{
    if (!m_nmModem || !m_nmModem->activeConnection() || !m_nmModem->activeConnection()->connection()) {
        return false;
    }

    auto connection = m_nmModem->activeConnection()->connection();
    NetworkManager::GsmSetting::Ptr gsmSetting = connection->settings()->setting(NetworkManager::Setting::Gsm).dynamicCast<NetworkManager::GsmSetting>();

    return gsmSetting ? !gsmSetting->homeOnly() : false;
}

QCoro::Task<void> Modem::setIsRoaming(bool roaming)
{
    if (!m_nmModem || !m_nmModem->activeConnection() || !m_nmModem->activeConnection()->connection()) {
        co_return;
    }

    auto connection = m_nmModem->activeConnection()->connection();

    NetworkManager::GsmSetting::Ptr gsmSetting = connection->settings()->setting(NetworkManager::Setting::Gsm).dynamicCast<NetworkManager::GsmSetting>();
    if (gsmSetting) {
        gsmSetting->setHomeOnly(!roaming); // set roaming setting

        QDBusReply<void> reply = co_await connection->update(connection->settings()->toMap());
        if (!reply.isValid()) {
            qWarning() << QStringLiteral("Error updating connection settings for") << connection->uuid() << QStringLiteral(":") << reply.error().message()
                       << QStringLiteral(".");
            CellularNetworkSettings::instance()->addMessage(
                InlineMessage::Error,
                i18n("Error updating connection settings for %1: %2.", connection->uuid(), reply.error().message()));
        } else {
            qDebug() << QStringLiteral("Successfully updated connection settings") << connection->uuid() << QStringLiteral(".");
        }
    }

    // the connection uni has changed, refresh the profiles list
    refreshProfiles();
    Q_EMIT activeConnectionUniChanged();
}

bool Modem::hasSim() const
{
    if (!m_mmModem) {
        return false;
    }
    return m_mmModem && m_mmModem->sim() && m_mmModem->sim()->uni() != QStringLiteral("/");
}

QList<ProfileSettings *> &Modem::profileList()
{
    return m_profileList;
}

void Modem::refreshProfiles()
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

QCoro::Task<void> Modem::activateProfile(const QString &connectionUni)
{
    if (!m_nmModem) {
        qWarning() << "Cannot activate profile since there is no NetworkManager modem";
        co_return;
    }

    qDebug() << QStringLiteral("Activating profile on modem") << m_nmModem->uni() << QStringLiteral("for connection") << connectionUni << ".";

    // cache roaming setting
    bool roaming = isRoaming();

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
    QDBusReply<QDBusObjectPath> reply = co_await NetworkManager::activateConnection(con->path(), m_nmModem->uni(), "");
    if (!reply.isValid()) {
        qWarning() << QStringLiteral("Error activating connection:") << reply.error().message();
        CellularNetworkSettings::instance()->addMessage(InlineMessage::Error, i18n("Error activating connection: %1", reply.error().message()));
        co_return;
    }

    // set roaming settings separately (since it changes the uni)
    co_await setIsRoaming(roaming);
}

QCoro::Task<void> Modem::addProfile(QString name, QString apn, QString username, QString password, QString networkType)
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
    gsmSetting->setHomeOnly(!isRoaming());

    gsmSetting->setInitialized(true);

    NetworkManager::Ipv6Setting::Ptr ipv6Setting = settings->setting(NetworkManager::Setting::Ipv6).dynamicCast<NetworkManager::Ipv6Setting>();
    ipv6Setting->setMethod(NetworkManager::Ipv6Setting::ConfigMethod::Automatic);
    ipv6Setting->setInitialized(true);

    QDBusReply<QDBusObjectPath> reply = co_await NetworkManager::addAndActivateConnection(settings->toMap(), m_nmModem->uni(), "");
    if (!reply.isValid()) {
        qWarning() << QStringLiteral("Error adding connection:") << reply.error().message();
        CellularNetworkSettings::instance()->addMessage(InlineMessage::Error, i18n("Error adding connection: %1", reply.error().message()));
    } else {
        qDebug() << QStringLiteral("Successfully added a new connection") << name << QStringLiteral("with APN") << apn << ".";
    }
}

QCoro::Task<void> Modem::removeProfile(const QString &connectionUni)
{
    NetworkManager::Connection::Ptr con = NetworkManager::findConnectionByUuid(connectionUni);
    if (!con) {
        qWarning() << QStringLiteral("Could not find connection") << connectionUni << QStringLiteral("to update!");
        co_return;
    }

    QDBusReply<void> reply = co_await con->remove();
    if (!reply.isValid()) {
        qWarning() << QStringLiteral("Error removing connection") << reply.error().message();
        CellularNetworkSettings::instance()->addMessage(InlineMessage::Error, i18n("Error removing connection: %1", reply.error().message()));
    }
}

QCoro::Task<void> Modem::updateProfile(QString connectionUni, QString name, QString apn, QString username, QString password, QString networkType)
{
    NetworkManager::Connection::Ptr con = NetworkManager::findConnectionByUuid(connectionUni);
    if (!con) {
        qWarning() << QStringLiteral("Could not find connection") << connectionUni << QStringLiteral("to update!");
        co_return;
    }

    NetworkManager::ConnectionSettings::Ptr conSettings = con->settings();
    if (!conSettings) {
        qWarning() << QStringLiteral("Could not find connection settings for") << connectionUni << QStringLiteral("to update!");
        co_return;
    }

    conSettings->setId(name);

    NetworkManager::GsmSetting::Ptr gsmSetting = conSettings->setting(NetworkManager::Setting::Gsm).dynamicCast<NetworkManager::GsmSetting>();
    gsmSetting->setApn(apn);
    gsmSetting->setUsername(username);
    gsmSetting->setPassword(password);
    gsmSetting->setPasswordFlags(password == "" ? NetworkManager::Setting::NotRequired : NetworkManager::Setting::AgentOwned);
    gsmSetting->setNetworkType(ProfileSettings::networkTypeFlag(networkType));
    gsmSetting->setHomeOnly(!isRoaming());

    gsmSetting->setInitialized(true);

    NetworkManager::Ipv6Setting::Ptr ipv6Setting = conSettings->setting(NetworkManager::Setting::Ipv6).dynamicCast<NetworkManager::Ipv6Setting>();
    ipv6Setting->setMethod(NetworkManager::Ipv6Setting::ConfigMethod::Automatic);
    ipv6Setting->setInitialized(true);

    QDBusReply<void> reply = con->update(conSettings->toMap());
    if (!reply.isValid()) {
        qWarning() << QStringLiteral("Error updating connection settings for") << connectionUni << QStringLiteral(":") << reply.error().message()
                   << QStringLiteral(".");
        CellularNetworkSettings::instance()->addMessage(InlineMessage::Error,
                                                        i18n("Error updating connection settings for %1: %2.", connectionUni, reply.error().message()));
    } else {
        qDebug() << QStringLiteral("Successfully updated connection settings") << connectionUni << QStringLiteral(".");
    }
}

void Modem::addDetectedProfileSettings()
{
    if (!m_mmModem) {
        qWarning() << "ModemManager device missing, cannot detect profile settings";
        return;
    }

    if (!hasSim() || !m_mmModem->sim()) {
        qWarning() << "No SIM found, cannot detect profile settings";
        return;
    }

    if (!m_mm3gppDevice) {
        qWarning() << "3gpp object not found, cannot detect profile settings";
        return;
    }

    bool found = false;
    static MobileProviders mobileProviders{};

    QString operatorCode = m_mmModem->sim()->operatorIdentifier();
    qWarning() << QStringLiteral("Detecting profile settings. Using MCCMNC:") << operatorCode;

    // lookup apns with mccmnc codes
    for (QString &provider : mobileProviders.getProvidersFromMCCMNC(operatorCode)) {
        qWarning() << QStringLiteral("Provider:") << provider;

        for (auto apn : mobileProviders.getApns(provider)) {
            QVariantMap apnInfo = mobileProviders.getApnInfo(apn);
            qWarning() << QStringLiteral("Found gsm profile settings. Type:") << apnInfo[QStringLiteral("usageType")];

            // only add mobile data apns (not mms)
            if (apnInfo[QStringLiteral("usageType")].toString() == QStringLiteral("internet")) {
                found = true;

                QString name = provider;
                if (!apnInfo[QStringLiteral("name")].isNull()) {
                    name += " - " + apnInfo[QStringLiteral("name")].toString();
                }

                addProfile(name,
                           apn,
                           apnInfo[QStringLiteral("username")].toString(),
                           apnInfo[QStringLiteral("password")].toString(),
                           QStringLiteral("4G/3G/2G"));
            }

            // TODO in the future for MMS settings, add else if here for == "mms"
        }
    }

    if (!found) {
        qDebug() << QStringLiteral("No profiles were found.");
        Q_EMIT couldNotAutodetectSettings();
    }
}

QList<Sim *> Modem::sims()
{
    return m_sims;
}

ModemManager::ModemDevice::Ptr Modem::mmModemDevice()
{
    return m_mmModem;
}

NetworkManager::ModemDevice::Ptr Modem::nmModemDevice()
{
    return m_nmModem;
}

ModemManager::Modem::Ptr Modem::mmModemInterface()
{
    return m_mmInterface;
}

QString Modem::nmDeviceStateStr(NetworkManager::Device::State state)
{
    if (state == NetworkManager::Device::State::UnknownState)
        return i18n("Unknown");
    else if (state == NetworkManager::Device::State::Unmanaged)
        return i18n("Unmanaged");
    else if (state == NetworkManager::Device::State::Unavailable)
        return i18n("Unavailable");
    else if (state == NetworkManager::Device::State::Disconnected)
        return i18n("Disconnected");
    else if (state == NetworkManager::Device::State::Preparing)
        return i18n("Preparing");
    else if (state == NetworkManager::Device::State::ConfiguringHardware)
        return i18n("ConfiguringHardware");
    else if (state == NetworkManager::Device::State::NeedAuth)
        return i18n("NeedAuth");
    else if (state == NetworkManager::Device::State::ConfiguringIp)
        return i18n("ConfiguringIp");
    else if (state == NetworkManager::Device::State::CheckingIp)
        return i18n("CheckingIp");
    else if (state == NetworkManager::Device::State::WaitingForSecondaries)
        return i18n("WaitingForSecondaries");
    else if (state == NetworkManager::Device::State::Activated)
        return i18n("Activated");
    else if (state == NetworkManager::Device::State::Deactivating)
        return i18n("Deactivating");
    else if (state == NetworkManager::Device::State::Failed)
        return i18n("Failed");
    else
        return "";
}
