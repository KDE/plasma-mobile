/*
 *   Copyright 2011 Sebastian Kügler <sebas@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2, or
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

#include "firstrun.h"
#include "kext.h"

#include <kactivitycontroller.h>
#include <kactivityinfo.h>

#include <Nepomuk/Query/QueryServiceClient>
#include <Nepomuk/Resource>
#include <Nepomuk/Variant>

#include <Plasma/DataEngine>
#include <Plasma/DataEngineManager>

#include <KConfig>
#include <soprano/vocabulary.h>

#include <QDBusConnection>
#include <QDBusServiceWatcher>
#include <QTimer>

FirstRun::FirstRun(QObject* parent)
    : QObject(parent),
    m_activityController(0)
{
    m_initialActivities << "Introduction" << "Vacation Planning" << "My First Activity";

    // wait until the system has settled down
    // yep, hack, but needed to prevent race conditions when nepomuk is no up yet :/
    if (Nepomuk::Query::QueryServiceClient::serviceAvailable()) {
        QTimer::singleShot(5000, this, SLOT(init()));
    } else {
        m_queryServiceWatcher = new QDBusServiceWatcher(QLatin1String("org.kde.nepomuk.services.nepomukqueryservice"),
                            QDBusConnection::sessionBus(),
                            QDBusServiceWatcher::WatchForRegistration,
                            this);
        connect(m_queryServiceWatcher, SIGNAL(serviceRegistered(QString)), this, SLOT(serviceRegistered(QString)));
    }
}

void FirstRun::serviceRegistered(const QString &service)
{
    if (service == "org.kde.nepomuk.services.nepomukqueryservice") {
        init();
    }
}

void FirstRun::init()
{
    KConfig* scfg = new KConfig("active-firstrunrc");
    KConfigGroup grp = scfg->group("general");
    bool hasRun = grp.readEntry("hasRun", false);
    delete scfg;
    kError() << "Starting first run ..." << !hasRun;
    if (!hasRun) {
        m_activityController = new KActivityController(this);
        m_currentActivity = m_activityController->currentActivity();
        QStringList activities = m_activityController->listActivities();
        foreach (const QString &id, activities) {
            activityAdded(id);
        }
        connect(m_activityController, SIGNAL(activityAdded(QString)), this, SLOT(activityAdded(QString)));
    } else {
        kError() << "Already ran, doing nothing";
        emit done();
    }
}

FirstRun::~FirstRun()
{
}

void FirstRun::activityAdded(const QString& source)
{
    KActivityInfo* info = new KActivityInfo(source);
    kError() << "------> Source added: " << info->name() << source;

    // Check if it's among the default activities and wether we've configured this actity already
    if (!m_initialActivities.contains(info->name())) {
        //kError() << "noinit";
        return;
    }
    if (m_completedActivities.contains(info->name())) {
        //kError() << "completed";
        return;
    }
    m_completedActivities << info->name();
    kError() << "------> Source added: " << info->name() << source;

    QString appPath = "/usr/share/applications/kde4/";

    //kError() << "AAA: " << info->name();
    if (info->name() == "Introduction") {
        // Bookmarks
        connectToActivity(source, "http://www.plasma-active.org", "Plasma Active");
    } else if (info->name() == "My First Activity") {
        // leaving it empty to invite creativity
    } else if (info->name() == "Vacation Planning") {
        // Bookmarks
        connectToActivity(source, "http://www.deutschebahn.com", "Deutsche Bahn");
        connectToActivity(source, "http://wikitravel.org/en/Berlin", "Berlin Travel Guide");
        connectToActivity(source, "http://osm.org/go/0MbEYhO8-", "OpenStreetMap Berlin");

        // Apps
        connectToActivity(source, appPath + "active-image-viewer.desktop");
        connectToActivity(source, appPath + "kwrite.desktop");
        connectToActivity(source, appPath + "korganizer-mobile.desktop");
    }

    if (m_completedActivities.size() == m_initialActivities.size()) {
        markDone();
        kError() << "All done. Quitting.";
        emit done();
    }
}

void FirstRun::connectToActivity(const QString &activityId, const QString &resourceUrl, const QString &description)
{
    Nepomuk::Resource fileRes(resourceUrl);
    QUrl typeUrl;

    //Bookmark?
    if (QUrl(resourceUrl).scheme() == "http") {
        typeUrl = QUrl("http://www.semanticdesktop.org/ontologies/2007/03/22/nfo#Bookmark");
        fileRes.addType(typeUrl);
        fileRes.setDescription(description);
        fileRes.setProperty(QUrl::fromEncoded("http://www.semanticdesktop.org/ontologies/2007/03/22/nfo#bookmarks"), resourceUrl);
    // App?
    } else if (resourceUrl.endsWith(".desktop")) {
        typeUrl = QUrl("http://www.semanticdesktop.org/ontologies/2007/03/22/nfo#Application");
        fileRes.addType(typeUrl);
        KService::Ptr service = KService::serviceByDesktopPath(QUrl(resourceUrl).path());
        if (service) {
            fileRes.setLabel(service->name());
            fileRes.setSymbols(QStringList() << service->icon());
        }
    }

    kError() << "       Added resource " << description << " to " << activityId;
    Nepomuk::Resource acRes(activityId, Nepomuk::Vocabulary::KEXT::Activity());
    acRes.addProperty(Soprano::Vocabulary::NAO::isRelated(), fileRes);
}

void FirstRun::markDone()
{
    kError() << "Noting in kconfig that we've run once.";
    KConfig* scfg = new KConfig("active-firstrunrc");
    KConfigGroup grp = scfg->group("general");
    grp.writeEntry("hasRun", true);
    scfg->sync();
    delete scfg;
}

#include "firstrun.moc"