/*
 *   Copyright (C) 2010 Marco Martin <mart@kde.org>
 *   Copyright (C) 2011 Ivan Cukic <ivan.cukic(at)kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License version 2 as
 *   published by the Free Software Foundation
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

#include "RecommendationsEngine.h"
#include "RecommendationsService.h"
#include "RecommendationItem.h"
#include "RecommendationManager.h"

#include <QDBusPendingCallWatcher>

#include <KDebug>

K_EXPORT_PLASMA_DATAENGINE(recommendations, Contour::RecommendationsEngine)

namespace Contour {

RecommendationsEngine::RecommendationsEngine(QObject* parent, const QVariantList& args)
    : Plasma::DataEngine(parent, args)
{
    setMinimumPollingInterval(2 * 1000); // 2 seconds minimum
}

RecommendationsEngine::~RecommendationsEngine()
{
}

void RecommendationsEngine::init()
{
    connect(RecommendationManager::self(), SIGNAL(recommendationsChanged(QList<Contour::RecommendationItem>)),
            this,                          SLOT(updateRecommendations(QList<Contour::RecommendationItem>)));
}

void RecommendationsEngine::updateRecommendations(const QList < Contour::RecommendationItem > & recommendations)
{
    kDebug() << "updating..." << recommendations.size();

    removeAllSources();
    m_recommendations.clear();

    foreach (const Contour::RecommendationItem & recommendation, recommendations) {
        QString recommendationId = recommendation.engine + " " + recommendation.id;
        m_recommendations[recommendationId] = recommendation;

        kDebug() << "Adding the" << recommendationId << m_recommendations[recommendationId].title;

        setData(recommendationId,  "name",         recommendation.title);
        setData(recommendationId,  "description",  recommendation.description);
        setData(recommendationId,  "icon",         recommendation.icon);
        setData(recommendationId,  "relevance",    recommendation.score);

    }
}

Plasma::Service *RecommendationsEngine::serviceForSource(const QString &source)
{
    if (!m_recommendations.contains(source)) {
        return 0;
    }

    kDebug() << source << m_recommendations[source].title << m_recommendations[source].engine;

    RecommendationService *service = new RecommendationService(m_recommendations.value(source), this);
    return service;
}

} // namespace Contour

#include "RecommendationsEngine.moc"
