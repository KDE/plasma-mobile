// SPDX-FileCopyrightText: 2021-2023 Devin Lin <espidev@gmail.com>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

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
                    const QString &name,
                    const QString &apn,
                    const QString &user,
                    const QString &password,
                    NetworkManager::GsmSetting::NetworkType networkType,
                    const QString &connectionUni);
    ProfileSettings(QObject *parent, NetworkManager::Setting::Ptr settings, NetworkManager::Connection::Ptr connection);

    QString name() const;
    QString apn() const;
    void setApn(const QString &apn);
    QString user() const;
    void setUser(const QString &user);
    QString password() const;
    void setPassword(const QString &password);
    QString networkType() const;
    void setNetworkType(const QString &ipType);
    QString connectionUni() const;

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
