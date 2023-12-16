/*
    SPDX-FileCopyrightText: 2018 Martin Kacej <m.kacej@atlas.sk>
    SPDX-FileCopyrightText: 2020-2021 Devin Lin <espidev@gmail.com>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

#include "cellularnetworksettings.h"

#include <KLocalizedString>
#include <KPluginFactory>
#include <KUser>

#include <QQmlEngine>

K_PLUGIN_CLASS_WITH_JSON(CellularNetworkSettings, "kcm_cellular_network.json")

CellularNetworkSettings *CellularNetworkSettings::staticInst = nullptr;

CellularNetworkSettings::CellularNetworkSettings(QObject *parent, const KPluginMetaData &metaData)
    : KQuickConfigModule(parent, metaData)
    , m_modemList{}
    , m_simList{}
{
    CellularNetworkSettings::staticInst = this;

    qmlRegisterType<ProfileSettings>("cellularnetworkkcm", 1, 0, "ProfileSettings");
    qmlRegisterType<Modem>("cellularnetworkkcm", 1, 0, "Modem");
    qmlRegisterType<ModemDetails>("cellularnetworkkcm", 1, 0, "ModemDetails");
    qmlRegisterType<AvailableNetwork>("cellularnetworkkcm", 1, 0, "AvailableNetwork");
    qmlRegisterType<Sim>("cellularnetworkkcm", 1, 0, "Sim");
    qmlRegisterType<InlineMessage>("cellularnetworkkcm", 1, 0, "InlineMessage");

    // find modems
    updateModemList();

    connect(ModemManager::notifier(), &ModemManager::Notifier::modemAdded, this, &CellularNetworkSettings::updateModemList);
    connect(ModemManager::notifier(), &ModemManager::Notifier::modemRemoved, this, &CellularNetworkSettings::updateModemList);
}

CellularNetworkSettings *CellularNetworkSettings::instance()
{
    return CellularNetworkSettings::staticInst;
}

Modem *CellularNetworkSettings::selectedModem()
{
    // TODO: we are currently assuming there is a single modem
    if (m_modemList.count() > 0) {
        return m_modemList[0];
    }
    return nullptr;
}

QList<Modem *> CellularNetworkSettings::modems()
{
    return m_modemList;
}

QList<Sim *> CellularNetworkSettings::sims()
{
    return m_simList;
}

bool CellularNetworkSettings::modemFound()
{
    return !m_modemList.empty();
}

void CellularNetworkSettings::updateModemList()
{
    // loop over every modem
    for (ModemManager::ModemDevice::Ptr device : ModemManager::modemDevices()) {
        ModemManager::Modem::Ptr modem = device->modemInterface();

        qDebug() << QStringLiteral("Found modem:") << device->uni();

        m_modemList.push_back(new Modem(this, device, modem));

        // update sims list if modem's list changes
        connect(m_modemList[m_modemList.size() - 1], &Modem::simsChanged, this, [this]() -> void {
            fillSims();
        });
    }

    if (m_modemList.empty()) {
        qDebug() << QStringLiteral("No modems found.");
    }

    // fill sim list
    fillSims();

    // update the currently selected modem
    Q_EMIT selectedModemChanged();
}

void CellularNetworkSettings::fillSims()
{
    for (auto p : m_simList) {
        delete p;
    }
    m_simList.clear();

    qDebug() << QStringLiteral("Scanning SIMs list...");
    for (auto modem : m_modemList) {
        auto sims = modem->sims();
        for (auto sim : sims) {
            qDebug() << QStringLiteral("Found SIM") << sim->uni() << sim->imsi();
            m_simList.push_back(sim);
        }
    }

    Q_EMIT simsChanged();
}

QList<InlineMessage *> CellularNetworkSettings::messages()
{
    return m_messages;
}

void CellularNetworkSettings::addMessage(InlineMessage::Type type, QString msg)
{
    m_messages.push_back(new InlineMessage{this, type, msg});
    Q_EMIT messagesChanged();
}

void CellularNetworkSettings::removeMessage(int index)
{
    if (index >= 0 && index < m_messages.size()) {
        m_messages.removeAt(index);
        Q_EMIT messagesChanged();
    }
}

InlineMessage::InlineMessage(QObject *parent, Type type, QString message)
    : QObject{parent}
    , m_type{type}
    , m_message{message}
{
}

InlineMessage::Type InlineMessage::type()
{
    return m_type;
}

QString InlineMessage::message()
{
    return m_message;
}

#include "cellularnetworksettings.moc"
