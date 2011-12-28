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

#ifndef NETWORK_NOTIFIER_H_
#define NETWORK_NOTIFIER_H_

#include <QObject>

class NetworkNotifier: public QObject {
    Q_OBJECT

public:
    NetworkNotifier(QObject * parent = NULL);
    virtual ~NetworkNotifier();

Q_SIGNALS:
    void activeAccessPointChanged(const QString & ssid);

protected Q_SLOTS:
    void setActiveAccessPoint(const QString & ssid);

    virtual void init() = 0;

    friend class NetworkNotifierLoader;
};

class NetworkNotifierLoader: public QObject {
    Q_OBJECT

public:
    static NetworkNotifierLoader * self();

    void registerNetworkNotifier(const QString & name, NetworkNotifier * nn);
    void init();

Q_SIGNALS:
    void activeAccessPointChanged(const QString & accessPoint, const QString & backend);

protected Q_SLOTS:
    void setActiveAccessPoint(const QString & accessPoint);

private:
    NetworkNotifierLoader();
    ~NetworkNotifierLoader();

    static NetworkNotifierLoader * s_instance;

private:
    class Private;
    Private * const d;
};

#define REGISTER_NETWORK_NOTIFIER(Name) \
    static class Name##StaticInit { public:    \
            Name##StaticInit() { NetworkNotifierLoader::self()->registerNetworkNotifier(#Name, new Name()); } \
    } Name##_static_init;

#endif // NETWORK_NOTIFIER_H_

