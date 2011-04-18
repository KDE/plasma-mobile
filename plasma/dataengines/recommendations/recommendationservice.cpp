/*
 *   Copyright 2011 Marco Martin <mart@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2 or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#include "recommendationservice.h"
#include "recommendationjob.h"

#include <recommendationsclient.h>

RecommendationService::RecommendationService(Contour::RecommendationsClient *client, Contour::Recommendation rec, QObject *parent)
    : Plasma::Service(parent),
      m_recommendationsClient(client),
      m_rec(rec)
{
    setName("recommendations");
}

ServiceJob *RecommendationService::createJob(const QString &operation,
                                             QMap<QString, QVariant> &parameters)
{
    return new RecommendationJob(m_recommendationsClient, m_rec, operation, parameters, this);
}

#include "recommendationservice.moc"
