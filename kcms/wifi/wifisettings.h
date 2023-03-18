/*
    SPDX-FileCopyrightText: 2018 Martin Kacej <m.kacej@atlas.sk>

    SPDX-License-Identifier: LGPL-2.0-or-later
*/

#ifndef WIFISETTINGS_H
#define WIFISETTINGS_H

#include <KQuickConfigModule>

class WifiSettings : public KQuickConfigModule
{
    Q_OBJECT
public:
    WifiSettings(QObject *parent, const KPluginMetaData &metaData, const QVariantList &args);
    Q_INVOKABLE QVariantMap getConnectionSettings(const QString &connection, const QString &type);
    Q_INVOKABLE QVariantMap getActiveConnectionInfo(const QString &connection);
    Q_INVOKABLE void addConnectionFromQML(const QVariantMap &QMLmap);
    Q_INVOKABLE void updateConnectionFromQML(const QString &path, const QVariantMap &map);
    Q_INVOKABLE QString getAccessPointDevice();
    Q_INVOKABLE QString getAccessPointConnection();
    virtual ~WifiSettings();
};

#endif // WIFISETTINGS_H
