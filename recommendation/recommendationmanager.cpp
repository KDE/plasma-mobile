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

#include "recommendationmanager.h"
#include "recommendation.h"
#include "locationmanager.h"

#include <kworkspace/kactivityinfo.h>
#include <kworkspace/kactivityconsumer.h>

#include <QtLocation/QLandmark>

QTM_USE_NAMESPACE


// TODO: act on several changes:
//       * activity change
//       * location change
//       * later: triggers from the dms

class Contour::RecommendationManager::Private
{
public:
    KActivityConsumer* m_activityConsumer;
    LocationManager* m_locationManager;
    QList<Recommendation*> m_recommendations;

    void updateRecommendations();
    void _k_locationChanged(const QList<QLandmark>&);
    void _k_currentActivityChanged(const QString&);
};


void Contour::RecommendationManager::Private::updateRecommendations()
{
}

void Contour::RecommendationManager::Private::_k_locationChanged(const QList<QLandmark>&)
{
    updateRecommendations();
}

void Contour::RecommendationManager::Private::_k_currentActivityChanged(const QString&)
{
    updateRecommendations();
}

Contour::RecommendationManager::RecommendationManager(QObject *parent)
    : QObject(parent),
      d(new Private())
{
    d->m_activityConsumer = new KActivityConsumer(this);
    connect(d->m_activityConsumer, SIGNAL(currentActivityChanged(QString)),
            this, SLOT(_k_currentActivityChanged(QString)));
    d->m_locationManager = new LocationManager(this);
    connect(d->m_locationManager, SIGNAL(locationChanged(QList<QLandmark>)),
            this, SLOT(_k_locationChanged(QList<QLandmark>)));
    d->updateRecommendations();
}

Contour::RecommendationManager::~RecommendationManager()
{
    delete d;
}

QList<Contour::Recommendation *> Contour::RecommendationManager::recommendations() const
{
    return d->m_recommendations;
}

#include "recommendationmanager.moc"
