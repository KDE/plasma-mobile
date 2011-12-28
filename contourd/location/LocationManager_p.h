/*
 *   Copyright (C) 2011 Ivan Cukic <ivan.cukic(at)kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License version 2,
 *   or (at your option) any later version, as published by the Free
 *   Software Foundation
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#ifndef LOCATION_MANAGER_P_H_
#define LOCATION_MANAGER_P_H_

#include "LocationManager.h"

#include <QHash>
#include <QUuid>

#include <KConfig>
#include <KConfigGroup>
#include <KDebug>

#include "network-engines/NetworkNotifier.h"
#include "locationmanageradaptor.h"

namespace Contour {

class LocationManager::Private: public QObject {
    Q_OBJECT

public:
    Private();
    virtual ~Private();

    void addNetworkToLocation(const QString & location, const QString & network);
    QString networkRoot(const QString & name);

    struct LocationInfo {
        QString name;
        QSet <QString> networks;
        QSet <QString> networkRoots;
    };

public Q_SLOTS:
    void scheduleConfigSync();
    void configSync();

public:
    QTimer configSyncTimer;

    QHash <QString, LocationInfo> knownLocationInfos;
    QHash <QString, QString>      knownLocationIds;

    KConfig config;
    KConfigGroup locationNames;
    KConfigGroup locationNetworks;
    KConfigGroup locationNetworkRoots;

    QString currentLocationId;
    QString currentNetworkName;
};


} // namespace Contour

#endif // LOCATION_MANAGER_P_H_
