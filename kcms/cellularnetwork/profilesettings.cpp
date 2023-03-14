// SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "profilesettings.h"

#include <KLocalizedString>

ProfileSettings::ProfileSettings(QObject *parent,
                                 QString name,
                                 QString apn,
                                 QString user,
                                 QString password,
                                 NetworkManager::GsmSetting::NetworkType networkType,
                                 QString connectionUni)
    : QObject{parent}
    , m_name(name)
    , m_apn(apn)
    , m_user(user)
    , m_password(password)
    , m_networkType(networkTypeStr(networkType))
    , m_connectionUni(connectionUni)
{
    setParent(parent);
}

ProfileSettings::ProfileSettings(QObject *parent, NetworkManager::Setting::Ptr setting, NetworkManager::Connection::Ptr connection)
    : QObject{parent}
    , m_connectionUni(connection->uuid())
{
    setParent(parent);

    NetworkManager::GsmSetting::Ptr gsmSetting = setting.staticCast<NetworkManager::GsmSetting>();

    m_name = connection->name();
    m_apn = gsmSetting->apn();
    m_user = gsmSetting->username();
    m_password = gsmSetting->password();
    m_networkType = networkTypeStr(gsmSetting->networkType());
}

QString ProfileSettings::name()
{
    return m_name;
}

QString ProfileSettings::apn()
{
    return m_apn;
}

void ProfileSettings::setApn(QString apn)
{
    if (apn != m_apn) {
        m_apn = apn;
        Q_EMIT apnChanged();
    }
}

QString ProfileSettings::user()
{
    return m_user;
}

void ProfileSettings::setUser(QString user)
{
    if (user != m_user) {
        m_user = user;
        Q_EMIT userChanged();
    }
}

QString ProfileSettings::password()
{
    return m_password;
}

void ProfileSettings::setPassword(QString password)
{
    if (password != m_password) {
        m_password = password;
        Q_EMIT passwordChanged();
    }
}

QString ProfileSettings::networkType()
{
    return m_networkType;
}

void ProfileSettings::setNetworkType(QString networkType)
{
    if (networkType != m_networkType) {
        m_networkType = networkType;
        Q_EMIT networkTypeChanged();
    }
}

QString ProfileSettings::connectionUni()
{
    return m_connectionUni;
}

QString ProfileSettings::networkTypeStr(NetworkManager::GsmSetting::NetworkType networkType)
{
    if (networkType == NetworkManager::GsmSetting::NetworkType::Any) {
        return QStringLiteral("Any");
    } else if (networkType == NetworkManager::GsmSetting::NetworkType::GprsEdgeOnly) {
        return QStringLiteral("Only 2G");
    } else if (networkType == NetworkManager::GsmSetting::NetworkType::Only3G) {
        return QStringLiteral("Only 3G");
    } else if (networkType == NetworkManager::GsmSetting::NetworkType::Only4GLte) {
        return QStringLiteral("Only 4G");
    } else if (networkType == NetworkManager::GsmSetting::NetworkType::Prefer2G) {
        return QStringLiteral("2G");
    } else if (networkType == NetworkManager::GsmSetting::NetworkType::Prefer3G) {
        return QStringLiteral("3G/2G");
    } else if (networkType == NetworkManager::GsmSetting::NetworkType::Prefer4GLte) {
        return QStringLiteral("4G/3G/2G");
    }
    return QStringLiteral("Any");
}

NetworkManager::GsmSetting::NetworkType ProfileSettings::networkTypeFlag(const QString &networkType)
{
    if (networkType == QStringLiteral("Any")) {
        return NetworkManager::GsmSetting::NetworkType::Any;
    } else if (networkType == QStringLiteral("Only 2G")) {
        return NetworkManager::GsmSetting::NetworkType::GprsEdgeOnly;
    } else if (networkType == QStringLiteral("Only 3G")) {
        return NetworkManager::GsmSetting::NetworkType::Only3G;
    } else if (networkType == QStringLiteral("Only 4G")) {
        return NetworkManager::GsmSetting::NetworkType::Only4GLte;
    } else if (networkType == QStringLiteral("2G")) {
        return NetworkManager::GsmSetting::NetworkType::Prefer2G;
    } else if (networkType == QStringLiteral("3G/2G")) {
        return NetworkManager::GsmSetting::NetworkType::Prefer3G;
    } else if (networkType == QStringLiteral("4G/3G/2G")) {
        return NetworkManager::GsmSetting::NetworkType::Prefer4GLte;
    }
    return NetworkManager::GsmSetting::NetworkType::Any;
}
