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
#include <Nepomuk/Variant>

#include <KDebug>
#include <KUrl>
#include <KFileItem>

#include "nfo.h"
#include "nie.h"
#include "kao.h"

#define KAMD_DBUS_ADDRESS "org.kde.ActivityManager"

using namespace Nepomuk::Vocabulary;

// Private

DocumentsEnginePrivate::DocumentsEnginePrivate(DocumentsEngine * parent)
    : q(parent)
{
    activitymanager = new KActivities::Consumer(this);

    QDBusConnection dbus = QDBusConnection::sessionBus();

    // Making us visible on d-bus
    new RankingsClientAdaptor(this);
    // kDebug() << "registering the client" <<
    dbus.registerObject("/RankingsClient", this);

    if (dbus.interface()->isServiceRegistered(KAMD_DBUS_ADDRESS)) {
        serviceOnline();
    }

    QDBusServiceWatcher * watcher = new QDBusServiceWatcher(
            KAMD_DBUS_ADDRESS, dbus,
            QDBusServiceWatcher::WatchForRegistration | QDBusServiceWatcher::WatchForUnregistration,
            this
        );
    connect(watcher, SIGNAL(serviceRegistered(QString)),
            this, SLOT(serviceOnline()));
    connect(watcher, SIGNAL(serviceUnregistered(QString)),
            this, SLOT(serviceOffline()));
}

void DocumentsEnginePrivate::serviceOnline()
{
    kDebug() << KAMD_DBUS_ADDRESS << "went online";

    QDBusInterface rankingsservice(KAMD_DBUS_ADDRESS,
            "/Rankings", "org.kde.ActivityManager.Rankings");

    rankingsservice.asyncCall("registerClient", "org.kde.Contour", QString(), "nao:Document");
}

void DocumentsEnginePrivate::serviceOffline()
{
    kDebug() << KAMD_DBUS_ADDRESS << "went offline";

    q->recommendationsUpdated(QList<Contour::RecommendationItem>());
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

        // The problem is when the resource has no particular type set (web page)
        // if (!resource.hasType(Nepomuk::Vocabulary::NFO::FileDataObject())) continue;

        Nepomuk::Resource currentActivityResource(activitymanager->currentActivity(), KAO::Activity());

        // TODO: See ActivityManager.coo
        // I'd like a resource isRelated activity more than vice-versa
        // but the active models are checking for the other way round.
        // It is defined in the ontologies as a symmetric relation, but
        // Nepomuk doesn't care about that.

        // if (resource.isRelateds().contains(currentActivityResource)) continue;
        if (currentActivityResource.isRelateds().contains(resource)) continue;

        Contour::RecommendationItem recommendation;

        recommendation.score       = score;
        recommendation.id          = item.toString();

        if (recommendation.id.startsWith("nepomuk:")) {
            if (!resource.hasProperty(NIE::url()))
                continue;

            recommendation.id = resource.property(NIE::url()).toString();
        }

        score /= 2;

        recommendation.title       = resource.genericLabel();

        if (recommendation.title.isEmpty()) {
            recommendation.title = recommendation.id;
        }

        recommendation.description = i18n("Open and add to the current activity");
        recommendation.icon        = resource.genericIcon();

        if (recommendation.icon.isEmpty()) {
            KFileItem fileItem(KFileItem::Unknown, KFileItem::Unknown,
                    KUrl(recommendation.id));
            recommendation.icon = fileItem.iconName();
        }

        kDebug()
            << "score:" << recommendation.score
            << "id:" << recommendation.id
            << "title:" << recommendation.title
            << "description:" << recommendation.description
            ;

        recommendations << recommendation;

        if (recommendations.size() >= 10) break;

    }

    q->recommendationsUpdated(recommendations);

}

void DocumentsEnginePrivate::removeRecommendation(const QString & id)
{
    // kDebug() << "removing" << id;

    for (int i = 0; i < recommendations.size(); i++) {
        if (recommendations[i].id == id) {
            // kDebug() << "before removal:" << recommendations;
            recommendations.removeAt(i);
            // kDebug() << "after removal:" << recommendations;
            break;
        }
    }
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
    Contour::RecommendationEngine::init();

    emit recommendationsUpdated(d->recommendations);
}

void DocumentsEngine::activate(const QString & id, const QString & action)
{
    KUrl url(id);

    d->removeRecommendation(id);

    // I *really* don't like this - handling http stuff as bookmarks, no matter
    // what they are...
    if (id.startsWith("http")) {
        // Evil handling of the resources - making bookmarks

        Nepomuk::Resource bookmark(url);

        // QList <QUrl> types;
        // types << NFO::Bookmark();

        // bookmark.setTypes(types);

        // We don't need the removal of other types since the
        // metadata model now filters bookmarks from normal document
        // types
        bookmark.addType(NFO::Bookmark());

    }

    // Proper handling of the resources
    d->activitymanager->linkResourceToActivity(url);

    QDesktopServices::openUrl(url);

    recommendationsUpdated(d->recommendations);
}

RECOMMENDATION_EXPORT_PLUGIN(DocumentsEngine, "contour_recommendationengine_documents")

