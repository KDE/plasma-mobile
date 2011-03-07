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

#include "locationmanager.h"

#include <QtLocation/QGeoPositionInfo>
#include <QtLocation/QGeoPositionInfoSource>
#include <QtLocation/QLandmarkProximityFilter>
#include <QtLocation/QLandmarkFetchRequest>



Contour::LocationManager::LocationManager(QObject *parent)
    : QObject(parent),
      m_lastLandmarkRequest(0)
{
    // create the landmark manager
    m_landmarkManager = new QLandmarkManager(QLatin1String("nepomuk-landmarkmanager"), QMap<QString, QString>(), this);

    // subscribe to geo location updates
    QGeoPositionInfoSource *source = QGeoPositionInfoSource::createDefaultSource(this);
    if (source) {
        source->setUpdateInterval(10000);
        connect(source, SIGNAL(positionUpdated(QGeoPositionInfo)),
                this, SLOT(slotGeoPositionChanged(QGeoPositionInfo)));
        slotGeoPositionChanged(source->lastKnownPosition());
        source->startUpdates();
    }
}

Contour::LocationManager::~LocationManager()
{
}

QList<QLandmark> Contour::LocationManager::currentLocations() const
{
    return m_currentLandmarks;
}

void Contour::LocationManager::slotGeoPositionChanged(const QGeoPositionInfo &pos)
{
    //
    // Cancel previous searches
    //
    if(m_lastLandmarkRequest) {
        m_lastLandmarkRequest->disconnect(this);
        m_lastLandmarkRequest->cancel();
        m_lastLandmarkRequest = 0;
    }

    //
    // Query for locations at the given position and compare to the current position
    //
    m_lastLandmarkRequest = new QLandmarkFetchRequest(m_landmarkManager, this);
    m_lastLandmarkRequest->setFilter(QLandmarkProximityFilter(pos.coordinate()));
    connect(m_lastLandmarkRequest, SIGNAL(resultsAvailable()),
            this, SLOT(slotLandmarkRequestDone()));
    m_lastLandmarkRequest->start();
}

void Contour::LocationManager::slotLandmarkRequestDone()
{
    QList<QLandmark> landmarks = m_lastLandmarkRequest->landmarks();
    m_lastLandmarkRequest = 0;

    if(m_currentLandmarks != landmarks) {
        m_currentLandmarks = landmarks;
        emit locationChanged(landmarks);
    }

    // TODO: check if we might need to propose a new location
    //       use the geo coordinate history as input:
    //       if we did not move more than N meters in the past
    //       M minutes it might be of interest.
}

#include "locationmanager.moc"
