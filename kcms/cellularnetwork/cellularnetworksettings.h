/*
    SPDX-FileCopyrightText: 2018 Martin Kacej <m.kacej@atlas.sk>
    SPDX-FileCopyrightText: 2020-2021 Devin Lin <espidev@gmail.com>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

#pragma once

#include <QSharedPointer>

#include <KQuickAddons/ConfigModule>

#include "mobileproviders.h"
#include "modem.h"
#include "modemdetails.h"
#include "sim.h"

#include <NetworkManagerQt/CdmaSetting>
#include <NetworkManagerQt/ConnectionSettings>
#include <NetworkManagerQt/GsmSetting>
#include <NetworkManagerQt/Manager>
#include <NetworkManagerQt/ModemDevice>
#include <NetworkManagerQt/Settings>

#include <ModemManagerQt/GenericTypes>
#include <ModemManagerQt/Manager>
#include <ModemManagerQt/ModemDevice>

class Sim;
class Modem;
class MobileProviders;

class InlineMessage : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int type READ type NOTIFY typeChanged)
    Q_PROPERTY(QString message READ message NOTIFY messageChanged)

public:
    enum Type {
        Information,
        Positive,
        Warning,
        Error,
    };

    InlineMessage(QObject *parent = nullptr, Type type = Information, QString message = "");

    Type type();
    QString message();

Q_SIGNALS:
    void typeChanged();
    void messageChanged();

private:
    Type m_type;
    QString m_message;
};

class CellularNetworkSettings : public KQuickAddons::ConfigModule
{
    Q_OBJECT
    Q_PROPERTY(bool modemFound READ modemFound NOTIFY modemFoundChanged)
    Q_PROPERTY(Modem *selectedModem READ selectedModem NOTIFY selectedModemChanged)
    Q_PROPERTY(QList<Sim *> sims READ sims NOTIFY simsChanged)
    Q_PROPERTY(QList<InlineMessage *> messages READ messages NOTIFY messagesChanged)

public:
    CellularNetworkSettings(QObject *parent, const KPluginMetaData &metaData, const QVariantList &args);

    static CellularNetworkSettings *instance();

    Modem *selectedModem();
    QList<Modem *> modems();
    QList<Sim *> sims();

    bool modemFound();

    QList<InlineMessage *> messages();
    void addMessage(InlineMessage::Type type, QString msg);
    Q_INVOKABLE void removeMessage(int index);

Q_SIGNALS:
    void modemFoundChanged();
    void selectedModemChanged();
    void simsChanged();
    void messagesChanged();

private:
    void updateModemList();
    void fillSims();

    QList<Modem *> m_modemList;
    QList<Sim *> m_simList;

    QList<InlineMessage *> m_messages;

    static CellularNetworkSettings *staticInst;
};
