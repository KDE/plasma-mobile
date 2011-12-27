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

#ifndef SOLID_NETWORK_NOTIFIER_H_
#define SOLID_NETWORK_NOTIFIER_H_

#include "NetworkNotifier.h"

/**
 * SolidNetworkNotifier
 */
class SolidNetworkNotifier: public NetworkNotifier {
    Q_OBJECT

public:
    SolidNetworkNotifier(QObject * parent = NULL);
    virtual ~SolidNetworkNotifier();

protected:
    void init();

private:
    class Private;
    Private * const d;
};

#endif // SOLIDNETWORK_NOTIFIER_H_

