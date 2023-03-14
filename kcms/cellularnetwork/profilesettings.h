// SPDX-FileCopyrightText: 2021-2022 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include "cellularnetworksettings.h"
#include "modemdetails.h"
#include "sim.h"

#include <QList>
#include <QString>

#include <NetworkManagerQt/CdmaSetting>
#include <NetworkManagerQt/ConnectionSettings>
#include <NetworkManagerQt/GsmSetting>
#include <NetworkManagerQt/Manager>
#include <NetworkManagerQt/ModemDevice>
#include <NetworkManagerQt/Settings>

#include <ModemManagerQt/GenericTypes>
#include <ModemManagerQt/Manager>
#include <ModemManagerQt/Modem3Gpp>
#include <ModemManagerQt/ModemDevice>

class ProfileSettings : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString name READ name NOTIFY nameChanged)
    Q_PROPERTY(QString apn READ apn WRITE setApn NOTIFY apnChanged)
    Q_PROPERTY(QString user READ user WRITE setUser NOTIFY userChanged)
    Q_PROPERTY(QString password READ password WRITE setPassword NOTIFY passwordChanged)
    Q_PROPERTY(QString networkType READ networkType WRITE setNetworkType NOTIFY networkTypeChanged)
    Q_PROPERTY(QString connectionUni READ connectionUni NOTIFY connectionUniChanged)

public:
    ProfileSettings(QObject *parent = nullptr)
        : QObject{parent}
    {
    }
    ProfileSettings(QObject *parent,
                    QString name,
                    QString apn,
                    QString user,
                    QString password,
                    NetworkManager::GsmSetting::NetworkType networkType,
                    QString connectionUni);
    ProfileSettings(QObject *parent, NetworkManager::Setting::Ptr settings, NetworkManager::Connection::Ptr connection);

    QString name();
    QString apn();
    void setApn(QString apn);
    QString user();
    void setUser(QString user);
    QString password();
    void setPassword(QString password);
    QString networkType();
    void setNetworkType(QString ipType);
    QString connectionUni();

    // utilities
    static QString networkTypeStr(NetworkManager::GsmSetting::NetworkType networkType);
    static NetworkManager::GsmSetting::NetworkType networkTypeFlag(const QString &networkType);

Q_SIGNALS:
    void nameChanged();
    void apnChanged();
    void userChanged();
    void passwordChanged();
    void networkTypeChanged();
    void connectionUniChanged();

private:
    QString m_name;
    QString m_apn;
    QString m_user;
    QString m_password;
    QString m_networkType;
    QString m_connectionUni;
};
