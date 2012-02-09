/*
 *   Copyright (C) 2012 Ivan Cukic <ivan.cukic(at)kde.org>
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

#ifndef ENGINE_H_
#define ENGINE_H_

#include <Plasma/PopupApplet>

class Engine: public QObject {
    Q_OBJECT

    Q_PROPERTY(QString currentLocationId READ currentLocationId NOTIFY currentLocationIdChanged)
    Q_PROPERTY(QString currentLocationName READ currentLocationName NOTIFY currentLocationNameChanged)

public:
    Engine(Plasma::PopupApplet * parent);

public Q_SLOTS:
    void setIcon(const QString & icon);
    void setCurrentLocation(const QString & location);

    QString currentLocationId() const;
    QString currentLocationName() const;

    void requestUiReset();

Q_SIGNALS:
    void currentLocationIdChanged(const QString & id);
    void currentLocationNameChanged(const QString & name);

    void resetUiRequested();

private Q_SLOTS:
    void onCurrentLocationChanged(const QString & id, const QString & name);

private:
    class Private;
    Private * const d;
};

#endif // ENGINE_H_

