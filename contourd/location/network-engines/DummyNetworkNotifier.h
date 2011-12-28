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

#ifndef DUMMY_NETWORK_NOTIFIER_H_
#define DUMMY_NETWORK_NOTIFIER_H_

#include "NetworkNotifier.h"

/**
 * DummyNetworkNotifier
 */
class DummyNetworkNotifier: public NetworkNotifier {
    Q_OBJECT
    Q_CLASSINFO("D-Bus Interface", "org.kde.contour.LocationManager.DummyNetworkNotifier")

public:
    DummyNetworkNotifier(QObject * parent = NULL);
    virtual ~DummyNetworkNotifier();

public Q_SLOTS:
    void setWifiName(const QString & accessPoint);

protected:
    void init();

private:
    class Private;
    Private * const d;
};

#endif // DUMMYNETWORK_NOTIFIER_H_

