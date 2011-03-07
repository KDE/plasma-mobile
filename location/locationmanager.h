/*
   This file is part of the Nepomuk KDE project.
   Copyright (C) 2011 Sebastian Trueg <trueg@kde.org>

   This library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 2.1 of the License, or (at your option) version 3, or any
   later version accepted by the membership of KDE e.V. (or its
   successor approved by the membership of KDE e.V.), which shall
   act as a proxy defined in Section 6 of version 3 of the license.

   This library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Lesser General Public License for more details.

   You should have received a copy of the GNU Lesser General Public
   License along with this library.  If not, see <http://www.gnu.org/licenses/>.
*/

#ifndef LOCATIONMANAGER_H
#define LOCATIONMANAGER_H

#include <QtCore/QObject>
#include <QtCore/QList>
#include <QtLocation/QLandmark>
#include <QtLocation/QGeoPositionInfo>
#include <QtLocation/QLandmarkFetchRequest>
#include <QtLocation/QLandmarkManager>

QTM_USE_NAMESPACE


namespace Contour {
/**
 * The location manager provides two things:
 * \li It informs about location changes, ie. entering the office, leaving home, etc.
 * \li It recommends new locations to save based on certain criteria like events,
 *     addresses, time of stay, etc.
 */
class LocationManager : public QObject
{
    Q_OBJECT

public:
    /**
     * Create a new location manager.
     */
    LocationManager(QObject *parent = 0);

    /**
     * Destructor.
     */
    ~LocationManager();

    /**
     * \return The current locations if there are known ones. Otherwise
     * returns an ampty list.
     * One can be in several locations at once: a country contains a
     * city and a city contains an office building which contains an office.
     */
    QList<QLandmark> currentLocations() const;

signals:
    /**
     * Emitted when the location changes.
     * \param landmarks The new locations or an ampty list in case
     * the new location is not known (leaving current location).
     *
     * \sa currentLocations()
     */
    void locationChanged(const QList<QLandmark>& landmarks);

    /**
     * Emitted when the manager detects a possible new location.
     * The new location will not be complete, it may or may not have a name and
     * description set. If not the UI should provide some action like
     * "Create new location here".
     */
    void possibleNewLocation(const QLandmark& landmark);

private slots:
    void slotGeoPositionChanged(const QGeoPositionInfo& pos);
    void slotLandmarkRequestDone();

private:
    QLandmarkManager* m_landmarkManager;

    /// The last unfinished request started to fetch known locations
    QLandmarkFetchRequest* m_lastLandmarkRequest;

    /// a list of landmarks we are currently at
    /// this is a list since we could be in a country and a city at the same time
    QList<QLandmark> m_currentLandmarks;
};
}

#endif
