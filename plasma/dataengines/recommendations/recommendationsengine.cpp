/*
 *   Copyright (C) 2010 Marco Martin <mart@kde.org>
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

#include "recommendationsengine.h"
#include "testsource.h"

#include <QDBusPendingCallWatcher>

#include <KDebug>

#include <Nepomuk/Resource>

#include <recommendationsclient.h>
#include <recommendation.h>

RecommendationsEngine::RecommendationsEngine(QObject* parent, const QVariantList& args)
    : Plasma::DataEngine(parent, args)
{
    setMinimumPollingInterval(2 * 1000); // 2 seconds minimum

    m_recommendationsClient = new Contour::RecommendationsClient(this);
    connect(m_recommendationsClient, SIGNAL(recommendationsChanged(const QList<Contour::Recommendation*> &)), this, SLOT(updateRecommendations(const QList<Contour::Recommendation*> &)));
}

RecommendationsEngine::~RecommendationsEngine()
{
}

void RecommendationsEngine::updateRecommendations(const QList<Contour::Recommendation*> &recommendations)
{
    kWarning()<<"New recommendations: "<<recommendations;

    foreach (Contour::Recommendation *rec, recommendations) {
        setData(rec->resource().uri(), "name", rec->resource().genericLabel());
        setData(rec->resource().uri(), "description", rec->resource().genericDescription());
        setData(rec->resource().uri(), "icon", rec->resource().genericIcon());
        setData(rec->resource().uri(), "relevance", rec->relevance());
    }
}

/*bool RecommendationsEngine::sourceRequestEvent(const QString &name)
{
    if (!name.startsWith("test") ) {
        return false;
    }

    updateSourceEvent(name); //start a download
    return true;
}


bool RecommendationsEngine::updateSourceEvent(const QString &name)
{
    kDebug() << name;


    TestSource *source = dynamic_cast<TestSource*>(containerForSource(name));

    if (!source) {
        source = new TestSource(this);
        source->setObjectName(name);

        addSource(source);
    }


    source->update();
    return false;
}*/

#include "recommendationsengine.moc"
