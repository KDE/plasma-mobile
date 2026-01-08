// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later OR LicenseRef-KDE-Accepted-GPL

#include <KIO/CommandLauncherJob>
#include <KNotificationJobUiDelegate>
#include <KPluginFactory>
#include <KRuntimePlatform>
#include <KUser>

#include <QDBusReply>
#include <QDebug>
#include <QDomDocument>
#include <QDomElement>
#include <QFile>
#include <QLoggingCategory>
#include <QPointer>
#include <QStandardPaths>

#include <NetworkManagerQt/CdmaSetting>
#include <NetworkManagerQt/ConnectionSettings>
#include <NetworkManagerQt/GsmSetting>
#include <NetworkManagerQt/Ipv6Setting>
#include <NetworkManagerQt/Manager>
#include <NetworkManagerQt/Settings>

#include <ModemManagerQt/Manager>
#include <ModemManagerQt/Modem3Gpp>

#include "autodetectapn.h"

K_PLUGIN_FACTORY_WITH_JSON(StartFactory, "kded_plasma_mobile_autodetectapn.json", registerPlugin<AutoDetectAPN>();)

static const QLoggingCategory LOGGING_CATEGORY("plasma-mobile-autodetectapn");

AutoDetectAPN::AutoDetectAPN(QObject *parent, const QList<QVariant> &)
    : KDEDModule{parent}
{
    checkAndAddAutodetectedAPN();
}

QCoro::Task<void> AutoDetectAPN::checkAndAddAutodetectedAPN()
{
    if (!KRuntimePlatform::runtimePlatform().contains(QStringLiteral("phone"))) {
        qCDebug(LOGGING_CATEGORY) << "Not running APN autodetection because this is not a Plasma Mobile session...";
        co_return;
    }

    qCDebug(LOGGING_CATEGORY) << "Running APN autodetection...";

    for (ModemManager::ModemDevice::Ptr mmDevice : ModemManager::modemDevices()) {
        ModemManager::Modem::Ptr mmModem = mmDevice->modemInterface();

        if (!mmModem) {
            continue;
        }

        const NetworkManager::ModemDevice::Ptr nmModem = findNMModem(mmModem);
        const ModemManager::Sim::Ptr mmSim = mmDevice->sim();

        if (!nmModem || !mmSim) {
            continue;
        }

        // Detect whether the modem already has an APN
        // TODO: currently just check if there are any NM connections, this doesn't work if the user swapped out their SIM.
        //       we need something that detects when this occurs
        if (!nmModem->availableConnections().empty()) {
            qCDebug(LOGGING_CATEGORY) << "Modem" << nmModem->uni() << "already has a connection configured";
            continue;
        }

        // MCCMNC value
        const QString operatorCode = mmSim->operatorIdentifier();
        const QString gid1 = mmSim->gid1(); // for carriers using MVNO, which could cause duplicate MCCMNC values
        const QString spn = mmSim->operatorName();
        const QString imsi = mmSim->imsi();

        // Autodetect an APN
        std::optional<APNEntry> detectedAPNOpt = findAPN(operatorCode, gid1, spn, imsi);
        if (detectedAPNOpt == std::nullopt || (*detectedAPNOpt).apn.isEmpty()) {
            qCDebug(LOGGING_CATEGORY) << "Could not find an APN for the SIM with code" << operatorCode;
            continue;
        }

        APNEntry detectedAPN = *detectedAPNOpt;

        // Create connection
        NetworkManager::ConnectionSettings::Ptr settings{new NetworkManager::ConnectionSettings(NetworkManager::ConnectionSettings::Gsm)};
        settings->setId(detectedAPN.carrier);
        settings->setUuid(NetworkManager::ConnectionSettings::createNewUuid());
        settings->setAutoconnect(true);
        settings->addToPermissions(KUser().loginName(), QString());

        NetworkManager::GsmSetting::Ptr gsmSetting = settings->setting(NetworkManager::Setting::Gsm).dynamicCast<NetworkManager::GsmSetting>();
        gsmSetting->setApn(detectedAPN.apn);
        gsmSetting->setPasswordFlags(NetworkManager::Setting::NotRequired);
        gsmSetting->setNetworkType(NetworkManager::GsmSetting::NetworkType::Prefer4GLte);
        gsmSetting->setHomeOnly(false); // TODO respect modem roaming settings?
        gsmSetting->setInitialized(true);

        if (
            detectedAPN.protocol == QStringLiteral("IPV6")
            || detectedAPN.protocol == QStringLiteral("IPV4V6")
        ) {
            NetworkManager::Ipv6Setting::Ptr ipv6Setting = settings->setting(NetworkManager::Setting::Ipv6).dynamicCast<NetworkManager::Ipv6Setting>();
            ipv6Setting->setMethod(NetworkManager::Ipv6Setting::ConfigMethod::Automatic);
            ipv6Setting->setInitialized(true);
        }

        QPointer<AutoDetectAPN> guard(this);
        QDBusReply<QDBusObjectPath> reply = co_await NetworkManager::addAndActivateConnection(settings->toMap(), nmModem->uni(), "");

        if (!guard) {
            co_return;
        }

        if (!reply.isValid()) {
            qCWarning(LOGGING_CATEGORY) << "Error adding autodetected connection:" << reply.error().message();
        } else {
            qCDebug(LOGGING_CATEGORY) << "Successfully autodetected" << detectedAPN.carrier << "with APN" << detectedAPN.apn << ".";
        }
    }
}

NetworkManager::ModemDevice::Ptr AutoDetectAPN::findNMModem(ModemManager::Modem::Ptr mmModem)
{
    const auto interfaces = NetworkManager::networkInterfaces();
    for (const NetworkManager::Device::Ptr &nmDevice : interfaces) {
        if (nmDevice->udi() == mmModem->uni()) {
            return nmDevice.objectCast<NetworkManager::ModemDevice>();
        }
    }
    return nullptr;
}

std::optional<AutoDetectAPN::APNEntry> AutoDetectAPN::findAPN(const QString &operatorCode, const QString &gid1, const QString &spn, const QString &imsi) const
{
    const QString providersFile = QStandardPaths::locate(QStandardPaths::GenericDataLocation, QStringLiteral("plasma-mobile-apn-info/apns-full-conf.xml"));
    QFile file{providersFile};

    if (!file.open(QIODevice::ReadOnly)) {
        return std::nullopt;
    }

    QDomDocument document;
    document.setContent(&file);

    QDomElement root = document.documentElement();
    if (root.isNull()) {
        return std::nullopt;
    }

    QDomNode apns = root.firstChild(); // <apns ...
    if (apns.isNull()) {
        return std::nullopt;
    }

    QList<APNEntry> candidates;

    QDomNode node = apns.firstChild(); // <apn ...
    while (!node.isNull()) {
        QDomElement element = node.toElement();

        // only entries for internet
        if (!element.attribute("type").contains("default")) {
            continue;
        }

        QString mccmnc = element.attribute("mcc") + element.attribute("mnc");

        if (mccmnc == operatorCode) {
            APNEntry entry{element.attribute("apn"), element.attribute("carrier"), element.attribute("protocol", "IPV4V6")};
            candidates.push_back(entry);

            // check if we have an MVNO match and prioritize that
            if ((!gid1.isEmpty() && element.attribute("mvno_type") == "gid" && element.attribute("mvno_match_data") == gid1)
                || (!spn.isEmpty() && element.attribute("mvno_type") == "spn" && element.attribute("mvno_match_data") == spn)
                || (!imsi.isEmpty() && element.attribute("mvno_type") == "imsi" && imsi.startsWith(element.attribute("mvno_match_data")))) {
                return {entry};
            }
        }

        node = node.nextSibling();
    }

    if (candidates.size() > 0) {
        return {candidates[0]};
    } else {
        return std::nullopt;
    }
}

#include "autodetectapn.moc"
