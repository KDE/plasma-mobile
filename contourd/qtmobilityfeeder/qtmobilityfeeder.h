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

#ifndef QT_MOBILITY_FEEDER_H_
#define QT_MOBILITY_FEEDER_H_

#include <QObject>

#include <QtContacts/QContact>

using namespace QtMobility;

namespace Contour {

class QtMobilityFeederPrivate;

/**
 *
 */
class QtMobilityFeeder: QObject {
    Q_OBJECT

public:
    QtMobilityFeeder(QObject* parent = 0);
    virtual ~QtMobilityFeeder();

private Q_SLOTS:
    void contactsAdded(const QList < QContactLocalId > & contactIds);
    void contactsChanged(const QList < QContactLocalId > & contactIds);
    void contactsRemoved(const QList < QContactLocalId > & contactIds);
    void dataChanged();

private:
    void updateContact(const QContact & contact);

    class QtMobilityFeederPrivate * const d;
};

} // namespace Contour

#endif // QT_MOBILITY_FEEDER_H_

