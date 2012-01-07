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

#ifndef LOCATION_MANAGER_H
#define LOCATION_MANAGER_H

#include <QObject>
#include <QString>
#include <QStringList>

namespace Contour {

/**
 * LocationManager
 */
class LocationManager: public QObject {
    Q_OBJECT
    Q_CLASSINFO("D-Bus Interface", "org.kde.contour.LocationManager")

public:
    LocationManager(QObject * parent);
    virtual ~LocationManager();

public Q_SLOTS:
    /**
     * @returns the list of previously saved locations
     */
    QStringList knownLocations() const;

    /**
     * Adds a new location to the list of known locations
     * @param name the name of the location
     * @returns the id of the newly created location, or the
     *     id of the location with the specified name if it
     *     existed previously.
     */
    QString addLocation(const QString & name);

    /**
     * Sets the current location.
     *
     * If the function is invoked with an UUID, and the location
     * with that UUID doesn't exist, it will not change the current
     * location and will return the id of the old location instead.
     *
     * If the function is invoked with a name instead of an UUID,
     * and the location with that name doesn't exist, it will create a new
     * location and return the id of the newly created location.
     * @see addLocation
     *
     * If an empty string is passed, the location is considered unknown.
     * @see resetCurrentLocation
     *
     * @param id or the name of the location
     * @returns the id of the location
     */
    QString setCurrentLocation(const QString & id);

    /**
     * Sets the location to unknown.
     */
    void resetCurrentLocation();

    /**
     * @returns the id of the current location. Empty if the location is not set.
     */
    QString currentLocationId() const;

    /**
     * The names of locations are unique, but the user can change them
     * over time. If you need to save the current location to a configuration
     * file or somewhere else, don't save the name, but use the id.
     *
     * Otherwise, you can use the name.
     *
     * @returns the name of the current location. Empty if the location is not set.
     */
    QString currentLocationName() const;

Q_SIGNALS:
    /**
     * Emitted when the current location is changed
     * @param id the id of the new location. Empty if the location is not set.
     * @param name the name of the new location. Empty if the location is not set.
     */
    void currentLocationChanged(const QString & id, const QString & name);

protected Q_SLOTS:
    void setActiveAccessPoint(const QString & accessPoint, const QString & backend);

private:
    class Private;
    Private * const d;
};

} // namespace Contour

#endif // LOCATION_MANAGER_H

