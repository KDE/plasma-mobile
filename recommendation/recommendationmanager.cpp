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
#include "recommendationmanageradaptor.h"
#include "dbusoperators.h"
#include "recommendation.h"
#include "recommendationaction.h"
#include "locationmanager.h"
#include "kext.h"

#include <kworkspace/kactivityinfo.h>
#include <kworkspace/kactivityconsumer.h>

#include <KRandom>
#include <KRun>
#include <KDebug>

#include <Nepomuk/Query/Query>
#include <Nepomuk/Query/QueryServiceClient>
#include <Nepomuk/Query/ComparisonTerm>
#include <Nepomuk/Query/LiteralTerm>
#include <Nepomuk/Query/AndTerm>
#include <Nepomuk/Query/QueryServiceClient>
#include <Nepomuk/Query/Result>
#include <Nepomuk/Resource>

#include <Soprano/Vocabulary/NAO>

#include <QtDBus/QDBusConnection>
#include <QtDBus/QDBusMetaType>

#include <QtLocation/QLandmark>

using namespace Soprano::Vocabulary;
using namespace Nepomuk::Vocabulary;

QTM_USE_NAMESPACE

Q_DECLARE_METATYPE(Contour::Recommendation*)


// TODO: act on several changes:
//       * later: triggers from the dms

class Contour::RecommendationManager::Private
{
public:
    KActivityConsumer* m_activityConsumer;
    LocationManager* m_locationManager;

    QList<Recommendation*> m_recommendations;
    QHash<QString, RecommendationAction*> m_actionHash;

    Nepomuk::Query::QueryServiceClient m_queryClient;

    RecommendationManager* q;

    void updateRecommendations();
    void _k_locationChanged(const QList<QLandmark>&);
    void _k_currentActivityChanged(const QString&);
    void _k_newResults(const QList<Nepomuk::Query::Result>&);
    void _k_queryFinished();
};


void Contour::RecommendationManager::Private::updateRecommendations()
{
    // remove old recommendations
    qDeleteAll(m_recommendations);
    m_recommendations.clear();
    m_actionHash.clear();

    // TODO: get some dummy recommendations for now
    //       for example: all files that were touched in this activity

    // get resources that have been touched in the current activity
    // FIXME: sort them by something
    const QString query
            = QString::fromLatin1("select ?r where { graph ?g { ?r ?p ?o . } . ?g %1 ?a . ?a %2 %3 . } LIMIT 6")
            .arg(Soprano::Node::resourceToN3(KExt::usedActivity()),
                 Soprano::Node::resourceToN3(NAO::identifier()),
                 Soprano::Node::literalToN3(Soprano::LiteralValue(m_activityConsumer->currentActivity())));

    m_queryClient.sparqlQuery(query);

    // IDEA: for files use usage events
    //       for everything else use changes in data via graph metadata
}

void Contour::RecommendationManager::Private::_k_locationChanged(const QList<QLandmark>&)
{
    updateRecommendations();
}

void Contour::RecommendationManager::Private::_k_currentActivityChanged(const QString&)
{
    updateRecommendations();
}

void Contour::RecommendationManager::Private::_k_newResults(const QList<Nepomuk::Query::Result>& results)
{
    foreach(const Nepomuk::Query::Result& result, results) {
        Recommendation* r = new Recommendation(result.resource(), result.score());

        // for now we create the one dummy action: open the resource
        QString id;
        do {
            id = KRandom::randomString(5);
        } while(!m_actionHash.contains(id));
        RecommendationAction* action = new RecommendationAction(r);
        action->setId(id);
        action->setText(i18n("Open '%1'", result.resource().genericLabel()));
        m_actionHash[id] = action;

        r->addAction(action);

        m_recommendations << r;
    }
}

void Contour::RecommendationManager::Private::_k_queryFinished()
{
    emit q->recommendationsChanged();
}

Contour::RecommendationManager::RecommendationManager(QObject *parent)
    : QObject(parent),
      d(new Private())
{
    d->q = this;

    connect(&d->m_queryClient, SIGNAL(newEntries(QList<Nepomuk::Query::Result>)),
            this, SLOT(_k_newResults(QList<Nepomuk::Query::Result>)));

    d->m_activityConsumer = new KActivityConsumer(this);
    connect(d->m_activityConsumer, SIGNAL(currentActivityChanged(QString)),
            this, SLOT(_k_currentActivityChanged(QString)));
    d->m_locationManager = new LocationManager(this);
    connect(d->m_locationManager, SIGNAL(locationChanged(QList<QLandmark>)),
            this, SLOT(_k_locationChanged(QList<QLandmark>)));
    d->updateRecommendations();

    // export via DBus
    qDBusRegisterMetaType<Contour::Recommendation*>();
    (void)new RecommendationManagerAdaptor(this);
    QDBusConnection::sessionBus().registerObject(QLatin1String("/recommendationmanager"), this);
}

Contour::RecommendationManager::~RecommendationManager()
{
    delete d;
}

QList<Contour::Recommendation *> Contour::RecommendationManager::recommendations() const
{
    return d->m_recommendations;
}

void Contour::RecommendationManager::executeAction(const QString &actionId)
{
    if(d->m_actionHash.contains(actionId)) {
        RecommendationAction* action = d->m_actionHash[actionId];

        // FIXME: this is the hacky execution of the action, make it correct
        Recommendation* r = qobject_cast<Recommendation*>(action->parent());
        (void)new KRun(r->resource().resourceUri(), 0);
    }
    else {
        kDebug() << "Invalid action id encountered:" << actionId;
    }
}

#include "recommendationmanager.moc"
