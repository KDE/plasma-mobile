/*
    SPDX-FileCopyrightText: 2018 Martin Kacej <m.kacej@atlas.sk>

    SPDX-License-Identifier: LGPL-2.0-or-later
*/

#include "wifisettings.h"

#include <KLocalizedString>
#include <KPluginFactory>

#include <NetworkManagerQt/AccessPoint>
#include <NetworkManagerQt/ActiveConnection>
#include <NetworkManagerQt/Connection>
#include <NetworkManagerQt/ConnectionSettings>
#include <NetworkManagerQt/GsmSetting>
#include <NetworkManagerQt/Ipv4Setting>
#include <NetworkManagerQt/Manager>
#include <NetworkManagerQt/Settings>
#include <NetworkManagerQt/Utils>
#include <NetworkManagerQt/WiredDevice>
#include <NetworkManagerQt/WiredSetting>
#include <NetworkManagerQt/WirelessDevice>
#include <NetworkManagerQt/WirelessSetting>

K_PLUGIN_CLASS_WITH_JSON(WifiSettings, "kcm_mobile_wifi.json")

WifiSettings::WifiSettings(QObject *parent, const KPluginMetaData &metaData)
    : KQuickConfigModule(parent, metaData)
{
    setButtons({});
}

QVariantMap WifiSettings::getConnectionSettings(const QString &connection, const QString &type)
{
    if (type.isEmpty())
        return QVariantMap();

    NetworkManager::Connection::Ptr con = NetworkManager::findConnection(connection);
    if (!con)
        return QVariantMap();

    if (type == "secrets")
        return con->secrets(QLatin1String("802-11-wireless-security")).value().value(QLatin1String("802-11-wireless-security"));

    QVariantMap map = con->settings()->toMap().value(type);
    if (type == "ipv4") {
        NetworkManager::Ipv4Setting::Ptr ipSettings = NetworkManager::Ipv4Setting::Ptr(new NetworkManager::Ipv4Setting());
        ipSettings->fromMap(map);
        map.clear();
        if (ipSettings->method() == NetworkManager::Ipv4Setting::Automatic) {
            map.insert(QLatin1String("method"), QVariant(QLatin1String("auto")));
        }

        if (ipSettings->method() == NetworkManager::Ipv4Setting::Manual) {
            map.insert(QLatin1String("method"), QVariant(QLatin1String("manual")));
            map.insert(QLatin1String("address"), QVariant(ipSettings->addresses().first().ip().toString()));
            map.insert(QLatin1String("prefix"), QVariant(ipSettings->addresses().first().prefixLength()));
            map.insert(QLatin1String("gateway"), QVariant(ipSettings->addresses().first().gateway().toString()));
            map.insert(QLatin1String("dns"), QVariant(ipSettings->dns().first().toString()));
        }
    }
    return map;
}

QVariantMap WifiSettings::getActiveConnectionInfo(const QString &connection)
{
    if (connection.isEmpty())
        return QVariantMap();

    NetworkManager::ActiveConnection::Ptr activeCon;
    NetworkManager::Connection::Ptr con = NetworkManager::findConnection(connection);
    foreach (const NetworkManager::ActiveConnection::Ptr &active, NetworkManager::activeConnections()) {
        if (active->uuid() == con->uuid())
            activeCon = active;
    }

    if (!activeCon) {
        qWarning() << "Active" << connection << "not found";
        return QVariantMap();
    }

    QVariantMap map;
    if (activeCon->ipV4Config().addresses().count() > 0) {
        map.insert("address", QVariant(activeCon->ipV4Config().addresses().first().ip().toString()));
        map.insert("prefix", QVariant(activeCon->ipV4Config().addresses().first().netmask().toString()));
    }
    map.insert("gateway", QVariant(activeCon->ipV4Config().gateway()));
    if (activeCon->ipV4Config().nameservers().count() > 0)
        map.insert("dns", QVariant(activeCon->ipV4Config().nameservers().first().toString()));
    // qWarning() << map;
    return map;
}

void WifiSettings::addConnectionFromQML(const QVariantMap &QMLmap)
{
    if (QMLmap.isEmpty())
        return;

    NetworkManager::ConnectionSettings::Ptr connectionSettings =
        NetworkManager::ConnectionSettings::Ptr(new NetworkManager::ConnectionSettings(NetworkManager::ConnectionSettings::Wireless));
    connectionSettings->setId(QMLmap.value(QLatin1String("id")).toString());
    connectionSettings->setUuid(NetworkManager::ConnectionSettings::createNewUuid());

    NetworkManager::WirelessSetting::Ptr wirelessSettings = NetworkManager::WirelessSetting::Ptr(new NetworkManager::WirelessSetting());
    wirelessSettings->setSsid(QMLmap.value(QLatin1String("id")).toString().toUtf8());
    if (QMLmap["mode"].toString() == "infrastructure") {
        wirelessSettings->setMode(NetworkManager::WirelessSetting::Infrastructure);
        connectionSettings->setAutoconnect(true);
    }
    if (QMLmap["mode"].toString() == "ap") {
        wirelessSettings->setMode(NetworkManager::WirelessSetting::Ap);
        connectionSettings->setAutoconnect(false);
    }
    if (QMLmap.contains("hidden")) {
        wirelessSettings->setHidden(QMLmap.value("hidden").toBool());
    }

    NetworkManager::Ipv4Setting::Ptr ipSettings = NetworkManager::Ipv4Setting::Ptr(new NetworkManager::Ipv4Setting());
    if (QMLmap["method"] == QLatin1String("auto")) {
        ipSettings->setMethod(NetworkManager::Ipv4Setting::ConfigMethod::Automatic);
    }
    if (QMLmap["method"] == QLatin1String("shared")) {
        ipSettings->setMethod(NetworkManager::Ipv4Setting::ConfigMethod::Shared);
    }
    if (QMLmap["method"] == QLatin1String("manual")) {
        ipSettings->setMethod(NetworkManager::Ipv4Setting::ConfigMethod::Manual);
        NetworkManager::IpAddress ipaddr;
        ipaddr.setIp(QHostAddress(QMLmap["address"].toString()));
        ipaddr.setPrefixLength(QMLmap["prefix"].toInt());
        ipaddr.setGateway(QHostAddress(QMLmap["gateway"].toString()));
        ipSettings->setAddresses(QList<NetworkManager::IpAddress>({ipaddr}));
        ipSettings->setDns(QList<QHostAddress>({QHostAddress(QMLmap["dns"].toString())}));
    }

    NMVariantMapMap map = connectionSettings->toMap();
    map.insert("802-11-wireless", wirelessSettings->toMap());
    map.insert("ipv4", ipSettings->toMap());

    // TODO can't set password for AP
    // needs further inspection

    if (QMLmap.contains("802-11-wireless-security")) {
        QVariantMap securMap = QMLmap["802-11-wireless-security"].toMap();
        int type = securMap["type"].toInt();
        if (!type == NetworkManager::NoneSecurity) {
            NetworkManager::WirelessSecuritySetting::Ptr securitySettings =
                NetworkManager::WirelessSecuritySetting::Ptr(new NetworkManager::WirelessSecuritySetting());
            if (type == NetworkManager::Wpa2Psk) {
                if (QMLmap["mode"].toString() == "ap") {
                    securitySettings->setKeyMgmt(NetworkManager::WirelessSecuritySetting::KeyMgmt::WpaNone);
                } else {
                    securitySettings->setKeyMgmt(NetworkManager::WirelessSecuritySetting::KeyMgmt::WpaPsk);
                }
                securitySettings->setAuthAlg(NetworkManager::WirelessSecuritySetting::AuthAlg::Open);
                securitySettings->setPskFlags(NetworkManager::Setting::SecretFlagType::AgentOwned);
                securitySettings->setPsk(securMap["password"].toString());
            }
            if (type == NetworkManager::StaticWep) {
                securitySettings->setKeyMgmt(NetworkManager::WirelessSecuritySetting::KeyMgmt::Wep);
                securitySettings->setAuthAlg(NetworkManager::WirelessSecuritySetting::AuthAlg::Open);
                securitySettings->setWepKeyType(NetworkManager::WirelessSecuritySetting::WepKeyType::Hex);
                securitySettings->setWepKeyFlags(NetworkManager::Setting::SecretFlagType::AgentOwned);
                securitySettings->setWepKey0(securMap["password"].toString());
            }
            if (type == NetworkManager::SAE) {
                securitySettings->setKeyMgmt(NetworkManager::WirelessSecuritySetting::KeyMgmt::SAE);
                securitySettings->setAuthAlg(NetworkManager::WirelessSecuritySetting::AuthAlg::Open);
                securitySettings->setPskFlags(NetworkManager::Setting::SecretFlagType::AgentOwned);
                securitySettings->setPsk(securMap["password"].toString());
            }
            map.insert("802-11-wireless-security", securitySettings->toMap());
        }
    }
    // qWarning() << map;
    NetworkManager::addConnection(map);
}

void WifiSettings::updateConnectionFromQML(const QString &path, const QVariantMap &map)
{
    NetworkManager::Connection::Ptr con = NetworkManager::findConnection(path);
    if (!con)
        return;

    // qWarning() << map;
    if (map.contains("id"))
        con->settings()->setId(map.value("id").toString());

    NMVariantMapMap toUpdateMap = con->settings()->toMap();

    NetworkManager::Ipv4Setting::Ptr ipSetting = con->settings()->setting(NetworkManager::Setting::Ipv4).staticCast<NetworkManager::Ipv4Setting>();
    if (ipSetting->method() == NetworkManager::Ipv4Setting::Automatic || ipSetting->method() == NetworkManager::Ipv4Setting::Manual) {
        if (map.value("method") == "auto") {
            ipSetting->setMethod(NetworkManager::Ipv4Setting::Automatic);
        }

        if (map.value("method") == "manual") {
            ipSetting->setMethod(NetworkManager::Ipv4Setting::ConfigMethod::Manual);
            NetworkManager::IpAddress ipaddr;
            ipaddr.setIp(QHostAddress(map["address"].toString()));
            ipaddr.setPrefixLength(map["prefix"].toInt());
            ipaddr.setGateway(QHostAddress(map["gateway"].toString()));
            ipSetting->setAddresses(QList<NetworkManager::IpAddress>({ipaddr}));
            ipSetting->setDns(QList<QHostAddress>({QHostAddress(map["dns"].toString())}));
        }
        toUpdateMap.insert("ipv4", ipSetting->toMap());
    }

    NetworkManager::WirelessSetting::Ptr wirelessSetting =
        con->settings()->setting(NetworkManager::Setting::Wireless).staticCast<NetworkManager::WirelessSetting>();
    if (map.contains("hidden")) {
        wirelessSetting->setHidden(map.value("hidden").toBool());
    }
    if (map.contains("id")) {
        wirelessSetting->setSsid(map.value("id").toByteArray());
    }
    toUpdateMap.insert("802-11-wireless", wirelessSetting->toMap());

    if (map.contains("802-11-wireless-security")) {
        QVariantMap secMap = map.value("802-11-wireless-security").toMap();
        // qWarning() << secMap;
        NetworkManager::WirelessSecuritySetting::Ptr securitySetting =
            con->settings()->setting(NetworkManager::Setting::WirelessSecurity).staticCast<NetworkManager::WirelessSecuritySetting>();
        if ((securitySetting->keyMgmt() == NetworkManager::WirelessSecuritySetting::Wep) && (secMap.value("type") == NetworkManager::StaticWep)) {
            securitySetting->setWepKey0(secMap["password"].toString());
        }

        if ((securitySetting->keyMgmt() == NetworkManager::WirelessSecuritySetting::WpaPsk) && (secMap.value("type") == NetworkManager::Wpa2Psk)) {
            securitySetting->setPsk(secMap["password"].toString());
        }

        if ((securitySetting->keyMgmt() == NetworkManager::WirelessSecuritySetting::SAE) && (secMap.value("type") == NetworkManager::SAE)) {
            securitySetting->setPsk(secMap["password"].toString());
        }

        // TODO can't set password for AP
        // needs further inspection
        if (wirelessSetting->mode() == NetworkManager::WirelessSetting::Ap) {
            if (securitySetting->toMap().empty()) { // no security
                if (secMap.value("type") == NetworkManager::Wpa2Psk) {
                    securitySetting->setKeyMgmt(NetworkManager::WirelessSecuritySetting::WpaNone);
                    securitySetting->setPsk(secMap.value("password").toString());
                }
            }
            if (securitySetting->keyMgmt() == NetworkManager::WirelessSecuritySetting::WpaNone) {
                if (secMap.empty()) {
                    securitySetting->setKeyMgmt(NetworkManager::WirelessSecuritySetting::Unknown);
                }
                if (secMap.value("type") == NetworkManager::Wpa2Psk) {
                    securitySetting->setPsk(secMap.value("password").toString());
                }
            }
        }

        toUpdateMap.insert("802-11-wireless-security", securitySetting->toMap());
    }
    qWarning() << toUpdateMap;
    con->update(toUpdateMap);
}

QString WifiSettings::getAccessPointDevice()
{
    NetworkManager::WirelessDevice::Ptr device;
    foreach (const NetworkManager::Device::Ptr &dev, NetworkManager::networkInterfaces()) {
        if (dev->type() == NetworkManager::Device::Wifi) {
            device = dev.staticCast<NetworkManager::WirelessDevice>();
            if (device->wirelessCapabilities().testFlag(NetworkManager::WirelessDevice::ApCap))
                break; // we have wireless device with access point capability
        }
    }
    if (device) {
        return device->uni();
    } else {
        qWarning() << "No wireless device found";
    }
    return QString();
}

QString WifiSettings::getAccessPointConnection()
{
    foreach (const NetworkManager::Connection::Ptr &con, NetworkManager::listConnections()) {
        NetworkManager::Setting::Ptr d = con->settings()->setting(NetworkManager::Setting::Wireless);
        if (!d.isNull()) {
            if (d.staticCast<NetworkManager::WirelessSetting>()->mode() == NetworkManager::WirelessSetting::Ap) {
                return con->path();
            }
        }
    }
    return QString();
}

#include "wifisettings.moc"
