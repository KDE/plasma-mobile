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


#ifndef DBUSSENSOR_H_
#define DBUSSENSOR_H_

#include <QObject>

/**
 *
 */
class DBusSensor: public QObject {
    Q_OBJECT
    Q_PROPERTY(QString identifier READ identifier)

public:
    DBusSensor();
    virtual ~DBusSensor();

Q_SIGNALS:
    void serviceOwnerChanged(const QString & serviceName, const QString & oldOwner, const QString & newOwner);
    void serviceRegistered(const QString & serviceName);
    void serviceUnregistered(const QString & serviceName);

private Q_SLOTS:
    void __serviceRegistered(const QString & serviceName);
    void __serviceUnregistered(const QString & serviceName);

public Q_SLOTS:
    void call(const QString & service, const QString & object, const QString & type, const QString & method);

public:
    Q_INVOKABLE QString identifier() const;
    Q_INVOKABLE void watchFor(const QString & service);
    Q_INVOKABLE void watchAll();

private:
    class Private;
    Private * const d;
};


#endif // DBUSSENSOR_H_

