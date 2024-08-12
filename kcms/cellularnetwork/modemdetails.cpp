// SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "modemdetails.h"

#include <KLocalizedString>

#include <QDBusPendingCallWatcher>

ModemDetails::ModemDetails(QObject *parent, Modem *modem)
    : QObject{parent}
    , m_modem{modem}
    , m_scanNetworkWatcher{nullptr}
    , m_isScanningNetworks{false}
    , m_cachedScannedNetworks{}
{
    auto mmInterfacePointer = m_modem->m_mmInterface.data();
    connect(mmInterfacePointer, &ModemManager::Modem::accessTechnologiesChanged, this, [this]() -> void {
        Q_EMIT accessTechnologiesChanged();
    });
    connect(mmInterfacePointer, &ModemManager::Modem::deviceChanged, this, [this]() -> void {
        Q_EMIT deviceChanged();
    });
    connect(mmInterfacePointer, &ModemManager::Modem::deviceIdentifierChanged, this, [this]() -> void {
        Q_EMIT deviceIdentifierChanged();
    });
    connect(mmInterfacePointer, &ModemManager::Modem::driversChanged, this, [this]() -> void {
        Q_EMIT driversChanged();
    });
    connect(mmInterfacePointer, &ModemManager::Modem::equipmentIdentifierChanged, this, [this]() -> void {
        Q_EMIT equipmentIdentifierChanged();
    });
    connect(mmInterfacePointer, &ModemManager::Modem::manufacturerChanged, this, [this]() -> void {
        Q_EMIT manufacturerChanged();
    });
    connect(mmInterfacePointer, &ModemManager::Modem::modelChanged, this, [this]() -> void {
        Q_EMIT modelChanged();
    });
    connect(mmInterfacePointer, &ModemManager::Modem::ownNumbersChanged, this, [this]() -> void {
        Q_EMIT ownNumbersChanged();
    });
    connect(mmInterfacePointer, &ModemManager::Modem::pluginChanged, this, [this]() -> void {
        Q_EMIT pluginChanged();
    });
    connect(mmInterfacePointer, &ModemManager::Modem::powerStateChanged, this, [this]() -> void {
        Q_EMIT powerStateChanged();
    });
    connect(mmInterfacePointer, &ModemManager::Modem::revisionChanged, this, [this]() -> void {
        Q_EMIT revisionChanged();
    });
    connect(mmInterfacePointer, &ModemManager::Modem::signalQualityChanged, this, [this]() -> void {
        Q_EMIT signalQualityChanged();
    });
    connect(mmInterfacePointer, &ModemManager::Modem::simPathChanged, this, [this]() -> void {
        Q_EMIT simPathChanged();
    });
    connect(mmInterfacePointer, &ModemManager::Modem::stateChanged, this, [this]() -> void {
        Q_EMIT stateChanged();
    });
    connect(mmInterfacePointer, &ModemManager::Modem::stateFailedReasonChanged, this, [this]() -> void {
        Q_EMIT stateFailedReasonChanged();
    });

    if (m_modem->m_mm3gppDevice) {
        connect(m_modem->m_mm3gppDevice.data(), &ModemManager::Modem3gpp::operatorCodeChanged, this, [this]() -> void {
            Q_EMIT operatorCodeChanged();
        });
        connect(m_modem->m_mm3gppDevice.data(), &ModemManager::Modem3gpp::operatorNameChanged, this, [this]() -> void {
            Q_EMIT operatorNameChanged();
        });
        connect(m_modem->m_mm3gppDevice.data(), &ModemManager::Modem3gpp::registrationStateChanged, this, [this]() -> void {
            Q_EMIT registrationStateChanged();
            Q_EMIT m_modem->isRoamingChanged();
        });
    } else {
        qWarning() << QStringLiteral("3gpp device not found!");
    }

    // m_modem->m_nmModem may be nullptr, listen for updates
    connect(m_modem, &Modem::nmModemChanged, this, &ModemDetails::updateNMSignals);
    updateNMSignals();
}

void ModemDetails::updateNMSignals()
{
    if (m_modem->m_nmModem) {
        connect(m_modem->m_nmModem.data(), &NetworkManager::ModemDevice::firmwareVersionChanged, this, [this]() -> void {
            Q_EMIT firmwareVersionChanged();
        });
        connect(m_modem->m_nmModem.data(), &NetworkManager::ModemDevice::interfaceNameChanged, this, [this]() -> void {
            Q_EMIT interfaceNameChanged();
        });
        connect(m_modem->m_nmModem.data(), &NetworkManager::ModemDevice::meteredChanged, this, [this]() -> void {
            Q_EMIT meteredChanged();
        });
    }
}

ModemDetails &ModemDetails::operator=(ModemDetails &&other)
{
    swap(other);
    return *this;
}

void ModemDetails::swap(ModemDetails &other)
{
    std::swap(m_modem, other.m_modem);
    std::swap(m_cachedScannedNetworks, other.m_cachedScannedNetworks);
    std::swap(m_isScanningNetworks, other.m_isScanningNetworks);
    std::swap(m_scanNetworkWatcher, other.m_scanNetworkWatcher);
}

QStringList ModemDetails::accessTechnologies()
{
    QStringList list;
    auto flags = m_modem->m_mmInterface->accessTechnologies();
    if (flags & MM_MODEM_ACCESS_TECHNOLOGY_UNKNOWN) {
        list.push_back(i18n("Unknown"));
    }
    if (flags & MM_MODEM_ACCESS_TECHNOLOGY_POTS) {
        list.push_back(i18n("POTS"));
    }
    if (flags & MM_MODEM_ACCESS_TECHNOLOGY_GSM) {
        list.push_back(i18n("GSM"));
    }
    if (flags & MM_MODEM_ACCESS_TECHNOLOGY_GSM_COMPACT) {
        list.push_back(i18n("GSM Compact"));
    }
    if (flags & MM_MODEM_ACCESS_TECHNOLOGY_GPRS) {
        list.push_back(i18n("GPRS"));
    }
    if (flags & MM_MODEM_ACCESS_TECHNOLOGY_EDGE) {
        list.push_back(i18n("EDGE"));
    }
    if (flags & MM_MODEM_ACCESS_TECHNOLOGY_UMTS) {
        list.push_back(i18n("UMTS"));
    }
    if (flags & MM_MODEM_ACCESS_TECHNOLOGY_HSDPA) {
        list.push_back(i18n("HSDPA"));
    }
    if (flags & MM_MODEM_ACCESS_TECHNOLOGY_HSUPA) {
        list.push_back(i18n("HSUPA"));
    }
    if (flags & MM_MODEM_ACCESS_TECHNOLOGY_HSPA) {
        list.push_back(i18n("HSPA"));
    }
    if (flags & MM_MODEM_ACCESS_TECHNOLOGY_HSPA_PLUS) {
        list.push_back(i18n("HSPA+"));
    }
    if (flags & MM_MODEM_ACCESS_TECHNOLOGY_1XRTT) {
        list.push_back(i18n("CDMA2000 1xRTT"));
    }
    if (flags & MM_MODEM_ACCESS_TECHNOLOGY_EVDO0) {
        list.push_back(i18n("CDMA2000 EVDO-0"));
    }
    if (flags & MM_MODEM_ACCESS_TECHNOLOGY_EVDOA) {
        list.push_back(i18n("CDMA2000 EVDO-A"));
    }
    if (flags & MM_MODEM_ACCESS_TECHNOLOGY_EVDOB) {
        list.push_back(i18n("CDMA2000 EVDO-B"));
    }
    if (flags & MM_MODEM_ACCESS_TECHNOLOGY_LTE) {
        list.push_back(i18n("LTE"));
    }
    if (flags & MM_MODEM_ACCESS_TECHNOLOGY_5GNR) {
        list.push_back(i18n("5GNR"));
    }
    return list;
}

QString ModemDetails::device()
{
    return m_modem->m_mmInterface->device();
}

QString ModemDetails::deviceIdentifier()
{
    return m_modem->m_mmInterface->deviceIdentifier();
}

QStringList ModemDetails::drivers()
{
    return m_modem->m_mmInterface->drivers();
}

QString ModemDetails::equipmentIdentifier()
{
    return m_modem->m_mmInterface->equipmentIdentifier();
}

bool ModemDetails::isEnabled()
{
    return m_modem->m_mmInterface->isEnabled();
}

QString ModemDetails::manufacturer()
{
    return m_modem->m_mmInterface->manufacturer();
}

QString ModemDetails::model()
{
    return m_modem->m_mmInterface->model();
}

QStringList ModemDetails::ownNumbers()
{
    return m_modem->m_mmInterface->ownNumbers();
}

QString ModemDetails::plugin()
{
    return m_modem->m_mmInterface->plugin();
}

QString ModemDetails::powerState()
{
    switch (m_modem->m_mmInterface->powerState()) {
    case MM_MODEM_POWER_STATE_UNKNOWN:
        return i18n("Unknown");
    case MM_MODEM_POWER_STATE_OFF:
        return i18n("Off");
    case MM_MODEM_POWER_STATE_LOW:
        return i18n("Low-power mode");
    case MM_MODEM_POWER_STATE_ON:
        return i18n("Full power mode");
    }
    return {};
}

QString ModemDetails::revision()
{
    return m_modem->m_mmInterface->revision();
}

uint ModemDetails::signalQuality()
{
    return m_modem->m_mmInterface->signalQuality().signal;
}

QString ModemDetails::simPath()
{
    return m_modem->m_mmInterface->simPath();
}

QString ModemDetails::state()
{
    switch (m_modem->m_mmInterface->state()) {
    case MM_MODEM_STATE_FAILED:
        return i18n("Failed");
    case MM_MODEM_STATE_UNKNOWN:
        return i18n("Unknown");
    case MM_MODEM_STATE_INITIALIZING:
        return i18n("Initializing");
    case MM_MODEM_STATE_LOCKED:
        return i18n("Locked");
    case MM_MODEM_STATE_DISABLED:
        return i18n("Disabled");
    case MM_MODEM_STATE_DISABLING:
        return i18n("Disabling");
    case MM_MODEM_STATE_ENABLING:
        return i18n("Enabling");
    case MM_MODEM_STATE_ENABLED:
        return i18n("Enabled");
    case MM_MODEM_STATE_SEARCHING:
        return i18n("Searching for network provider");
    case MM_MODEM_STATE_REGISTERED:
        return i18n("Registered with network provider");
    case MM_MODEM_STATE_DISCONNECTING:
        return i18n("Disconnecting");
    case MM_MODEM_STATE_CONNECTING:
        return i18n("Connecting");
    case MM_MODEM_STATE_CONNECTED:
        return i18n("Connected");
    }
    return {};
}

QString ModemDetails::stateFailedReason()
{
    switch (m_modem->m_mmInterface->stateFailedReason()) {
    case MM_MODEM_STATE_FAILED_REASON_NONE:
        return i18n("No error.");
    case MM_MODEM_STATE_FAILED_REASON_UNKNOWN:
        return i18n("Unknown error.");
    case MM_MODEM_STATE_FAILED_REASON_SIM_MISSING:
        return i18n("SIM is required but missing.");
    case MM_MODEM_STATE_FAILED_REASON_SIM_ERROR:
        return i18n("SIM is available but unusable.");
    case MM_MODEM_STATE_FAILED_REASON_UNKNOWN_CAPABILITIES:
        return i18n("Unknown modem capabilities.");
    case MM_MODEM_STATE_FAILED_REASON_ESIM_WITHOUT_PROFILES:
        return i18n("eSIM is not initialized.");
    }
    return {};
}

QString ModemDetails::operatorCode()
{
    return m_modem->m_mm3gppDevice ? m_modem->m_mm3gppDevice->operatorCode() : QString{};
}

QString ModemDetails::operatorName()
{
    return m_modem->m_mm3gppDevice ? m_modem->m_mm3gppDevice->operatorName() : QString{};
}

QString ModemDetails::registrationState()
{
    if (!m_modem->m_mm3gppDevice) {
        return QString{};
    }

    switch (m_modem->m_mm3gppDevice->registrationState()) {
    case MM_MODEM_3GPP_REGISTRATION_STATE_IDLE:
        return i18n("Not registered, not searching for new operator to register.");
    case MM_MODEM_3GPP_REGISTRATION_STATE_HOME:
        return i18n("Registered on home network.");
    case MM_MODEM_3GPP_REGISTRATION_STATE_SEARCHING:
        return i18n("Not registered, searching for new operator to register with.");
    case MM_MODEM_3GPP_REGISTRATION_STATE_DENIED:
        return i18n("Registration denied.");
    case MM_MODEM_3GPP_REGISTRATION_STATE_UNKNOWN:
        return i18n("Unknown registration status.");
    case MM_MODEM_3GPP_REGISTRATION_STATE_ROAMING:
        return i18n("Registered on a roaming network.");
    case MM_MODEM_3GPP_REGISTRATION_STATE_HOME_SMS_ONLY:
        return i18n("Registered for \"SMS only\", on home network.");
    case MM_MODEM_3GPP_REGISTRATION_STATE_ROAMING_SMS_ONLY:
        return i18n("Registered for \"SMS only\", roaming network.");
    case MM_MODEM_3GPP_REGISTRATION_STATE_EMERGENCY_ONLY:
        return i18n("Emergency services only.");
    case MM_MODEM_3GPP_REGISTRATION_STATE_HOME_CSFB_NOT_PREFERRED:
        return i18n("Registered for \"CSFB not preferred\", home network.");
    case MM_MODEM_3GPP_REGISTRATION_STATE_ROAMING_CSFB_NOT_PREFERRED:
        return i18n("Registered for \"CSFB not preferred\", roaming network.");
    case MM_MODEM_3GPP_REGISTRATION_STATE_ATTACHED_RLOS:
        return i18n("Attached for access to Restricted Local Operator Services.");
    }
    return {};
}

Q_DECLARE_METATYPE(MMModem3gppNetworkAvailability)
Q_DECLARE_METATYPE(MMModemAccessTechnology)

QList<AvailableNetwork *> ModemDetails::networks()
{
    return m_cachedScannedNetworks;
}

Q_INVOKABLE void ModemDetails::scanNetworks()
{
    for (auto p : m_cachedScannedNetworks) {
        p->deleteLater();
    }
    m_cachedScannedNetworks.clear();

    if (m_modem->m_mm3gppDevice) {
        qDebug() << QStringLiteral("Scanning for available networks...");

        QDBusPendingReply<ModemManager::QVariantMapList> reply = m_modem->m_mm3gppDevice->scan();

        m_isScanningNetworks = true;
        Q_EMIT isScanningNetworksChanged();
        m_scanNetworkWatcher = new QDBusPendingCallWatcher(reply, this);
        connect(m_scanNetworkWatcher, &QDBusPendingCallWatcher::finished, this, &ModemDetails::scanNetworksFinished);
    }

    Q_EMIT networksChanged();
}

void ModemDetails::scanNetworksFinished(QDBusPendingCallWatcher *call)
{
    QDBusPendingReply<ModemManager::QVariantMapList> reply = *call;
    if (reply.isError()) {
        qDebug() << QStringLiteral("Scanning failed:") << reply.error().message();
        CellularNetworkSettings::instance()->addMessage(InlineMessage::Error, i18n("Scanning networks failed: %1", reply.error().message()));
    } else {
        ModemManager::QVariantMapList list = reply.value();

        for (auto &var : list) {
            auto status = var[QStringLiteral("status")].value<MMModem3gppNetworkAvailability>();

            if (status == MM_MODEM_3GPP_NETWORK_AVAILABILITY_CURRENT || status == MM_MODEM_3GPP_NETWORK_AVAILABILITY_AVAILABLE) {
                auto network = new AvailableNetwork{this,
                                                    m_modem->m_mm3gppDevice,
                                                    status == MM_MODEM_3GPP_NETWORK_AVAILABILITY_CURRENT,
                                                    var[QStringLiteral("operator-long")].toString(),
                                                    var[QStringLiteral("operator-short")].toString(),
                                                    var[QStringLiteral("operator-code")].toString(),
                                                    var[QStringLiteral("access-technology")].value<MMModemAccessTechnology>()};
                m_cachedScannedNetworks.push_back(network);
            }
        }
    }
    m_isScanningNetworks = false;
    Q_EMIT networksChanged();
    Q_EMIT isScanningNetworksChanged();

    call->deleteLater();
}

bool ModemDetails::isScanningNetworks()
{
    return m_isScanningNetworks;
}

QString ModemDetails::firmwareVersion()
{
    if (!m_modem->m_nmModem) {
        return QString{};
    }
    return m_modem->m_nmModem->firmwareVersion();
}

QString ModemDetails::interfaceName()
{
    if (!m_modem->m_nmModem) {
        return QString{};
    }
    return m_modem->m_nmModem->interfaceName();
}

QString ModemDetails::metered()
{
    if (!m_modem->m_nmModem) {
        return QString{};
    }

    switch (m_modem->m_nmModem->metered()) {
    case NetworkManager::Device::MeteredStatus::UnknownStatus:
        return i18n("Unknown");
    case NetworkManager::Device::MeteredStatus::Yes:
        return i18n("Yes");
    case NetworkManager::Device::MeteredStatus::No:
        return i18n("No");
    case NetworkManager::Device::MeteredStatus::GuessYes:
        return i18n("GuessYes");
    case NetworkManager::Device::MeteredStatus::GuessNo:
        return i18n("GuessNo");
    }
    return QString{};
}

AvailableNetwork::AvailableNetwork(QObject *parent,
                                   ModemManager::Modem3gpp::Ptr mm3gppDevice,
                                   bool isCurrentlyUsed,
                                   QString operatorLong,
                                   QString operatorShort,
                                   QString operatorCode,
                                   MMModemAccessTechnology accessTechnology)
    : QObject{parent}
    , m_isCurrentlyUsed{isCurrentlyUsed}
    , m_operatorLong{operatorLong}
    , m_operatorShort{operatorShort}
    , m_operatorCode{operatorCode}
    , m_accessTechnology{}
    , m_mm3gppDevice{mm3gppDevice}
{
    switch (accessTechnology) {
    case MM_MODEM_ACCESS_TECHNOLOGY_UNKNOWN:
        m_accessTechnology = i18n("Unknown");
        break;
    case MM_MODEM_ACCESS_TECHNOLOGY_POTS:
        m_accessTechnology = i18n("POTS");
        break;
    case MM_MODEM_ACCESS_TECHNOLOGY_GSM:
        m_accessTechnology = i18n("2G");
        break;
    case MM_MODEM_ACCESS_TECHNOLOGY_GSM_COMPACT:
        m_accessTechnology = i18n("2G");
        break;
    case MM_MODEM_ACCESS_TECHNOLOGY_GPRS:
        m_accessTechnology = i18n("2G");
        break;
    case MM_MODEM_ACCESS_TECHNOLOGY_EDGE:
        m_accessTechnology = i18n("2G");
        break;
    case MM_MODEM_ACCESS_TECHNOLOGY_UMTS:
        m_accessTechnology = i18n("3G");
        break;
    case MM_MODEM_ACCESS_TECHNOLOGY_HSDPA:
        m_accessTechnology = i18n("3G");
        break;
    case MM_MODEM_ACCESS_TECHNOLOGY_HSUPA:
        m_accessTechnology = i18n("3G");
        break;
    case MM_MODEM_ACCESS_TECHNOLOGY_HSPA:
        m_accessTechnology = i18n("3G");
        break;
    case MM_MODEM_ACCESS_TECHNOLOGY_HSPA_PLUS:
        m_accessTechnology = i18n("3G");
        break;
    case MM_MODEM_ACCESS_TECHNOLOGY_1XRTT:
        m_accessTechnology = i18n("3G");
        break;
    case MM_MODEM_ACCESS_TECHNOLOGY_EVDO0:
        m_accessTechnology = i18n("3G");
        break;
    case MM_MODEM_ACCESS_TECHNOLOGY_EVDOA:
        m_accessTechnology = i18n("3G");
        break;
    case MM_MODEM_ACCESS_TECHNOLOGY_EVDOB:
        m_accessTechnology = i18n("3G");
        break;
    case MM_MODEM_ACCESS_TECHNOLOGY_LTE:
        m_accessTechnology = i18n("4G");
        break;
    case MM_MODEM_ACCESS_TECHNOLOGY_5GNR:
        m_accessTechnology = i18n("5G");
        break;
    case MM_MODEM_ACCESS_TECHNOLOGY_ANY:
        m_accessTechnology = i18n("Any");
        break;
    case MM_MODEM_ACCESS_TECHNOLOGY_LTE_CAT_M:
        m_accessTechnology = i18n("4G");
        break;
    case MM_MODEM_ACCESS_TECHNOLOGY_LTE_NB_IOT:
        m_accessTechnology = i18n("4G");
        break;
    }
}

bool AvailableNetwork::isCurrentlyUsed()
{
    return m_isCurrentlyUsed;
}

QString AvailableNetwork::operatorLong()
{
    return m_operatorLong;
}

QString AvailableNetwork::operatorShort()
{
    return m_operatorShort;
}

QString AvailableNetwork::operatorCode()
{
    return m_operatorCode;
}

QString AvailableNetwork::accessTechnology()
{
    return m_accessTechnology;
}

void AvailableNetwork::registerToNetwork()
{
    if (!m_isCurrentlyUsed && m_mm3gppDevice) {
        m_mm3gppDevice->registerToNetwork(m_operatorCode);
    }
}
