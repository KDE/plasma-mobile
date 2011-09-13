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

#include "Documents.h"
#include "Documents_p.h"
#include "rankingsclientadaptor.h"

#include <QList>
#include <QDBusConnection>
#include <QDesktopServices>

#include <Nepomuk/Resource>

#include <KDebug>
#include <KUrl>

// Private

DocumentsEnginePrivate::DocumentsEnginePrivate(DocumentsEngine * parent)
    : q(parent)
{
    QDBusConnection dbus = QDBusConnection::sessionBus();
    new RankingsClientAdaptor(this);
    kDebug() << "registering the client" <<
    dbus.registerObject("/RankingsClient", this);

    QDBusInterface rankingsservice("org.kde.kactivitymanagerd",
            "/Rankings", "org.kde.ActivityManager.Rankings");

    kDebug() << "calling registerClient" <<
    rankingsservice.call("registerClient", "org.kde.Contour", QString(), "nao:Document");
}

DocumentsEnginePrivate::~DocumentsEnginePrivate()
{
}

void DocumentsEnginePrivate::updated(const QVariantList & data)
{
    kDebug() << "@@@@@@@@@@@@@@@@@@" << data;
    recommendations.clear();

    double score = 1.0;

    foreach (const QVariant & item, data) {
        Nepomuk::Resource resource(KUrl(item.toString()));

        Contour::RecommendationItem recommendation;

        recommendation.score       = score;
        recommendation.id          = item.toString();
        score /= 2;

        recommendation.title       = resource.genericLabel();
        recommendation.description = "Stay tuned";
        recommendation.icon        = "preferences-activities";

        kDebug() << recommendation;

        recommendations << recommendation;

    }

    q->recommendationsUpdated(recommendations);

}

void DocumentsEnginePrivate::inserted(int position, const QVariantList & item)
{
}

void DocumentsEnginePrivate::removed(int position)
{
}

void DocumentsEnginePrivate::changed(int position, const QVariantList & item)
{
}


// DocumentsEngine

DocumentsEngine::DocumentsEngine(QObject * parent, const QVariantList & args)
    : Contour::RecommendationEngine(parent), d(new DocumentsEnginePrivate(this))
{
}

DocumentsEngine::~DocumentsEngine()
{
    delete d;
}

void DocumentsEngine::init()
{
    kDebug() << "We are going to work";

    Contour::RecommendationItem recommendation;

    recommendation.score       = 1.0;
    recommendation.title       = "Not implemented yet";
    recommendation.description = "Stay tuned";
    recommendation.icon        = "preferences-activities";
    recommendation.id          = "null";

    d->recommendations << recommendation;

    emit recommendationsUpdated(d->recommendations);
}

void DocumentsEngine::activate(const QString & id, const QString & action)
{
    QDesktopServices::openUrl(KUrl(id));

}

RECOMMENDATION_EXPORT_PLUGIN(DocumentsEngine, "contour_recommendationengine_documents")

