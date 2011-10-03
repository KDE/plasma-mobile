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

#include <kactivitycontroller.h>
#include <kactivityinfo.h>

#include <Nepomuk/Resource>
#include <Nepomuk/Variant>

#include <Plasma/DataEngine>
#include <Plasma/DataEngineManager>

#include <KConfig>
#include <soprano/vocabulary.h>

FirstRun::FirstRun(QObject* parent)
    : QObject(parent),
    m_activityController(0)
{
    init();
}

void FirstRun::init()
{

    KConfig* scfg = new KConfig("active-firstrunrc");
    KConfigGroup grp = scfg->group("general");
    bool hasRun = grp.readEntry("hasRun", false);
    delete scfg;
    kError() << "Starting first run ..." << hasRun;
    if (!hasRun) {
        m_activityController = new KActivityController(this);
        m_currentActivity = m_activityController->currentActivity();
        QStringList activities = m_activityController->listActivities();
        //setData("allActivities", activities);
        foreach (const QString &id, activities) {
            kError() << "Activity: " << id;
            activityAdded(id);        }
        connect(m_activityController, SIGNAL(activityAdded(QString)), this, SLOT(activityAdded(QString)));
    } else {
        kError() << "Already ran, doing nothing";
    }
    kError() << "Done.";
    emit done();
    markDone();
}

FirstRun::~FirstRun()
{
}

void FirstRun::activityAdded(const QString& source)
{
    kError() << "Source added: " << source;
    if (!source.isEmpty()) {
        KActivityInfo* info = new KActivityInfo(source);
        kError() << "AAA: " << info->name();
        if (info->name() == "Introduction") {
            connectToActivity("http://en.wikipedia.org/wiki/Berlin", source, "Wikipedia: Berlin");
            connectToActivity("http://wikitravel.org/wiki/Berlin", source, "Wikitravel: Berlin");
            connectToActivity("http://maps.google.com", source);
        } else if (info->name() == "My First Activity") {
            connectToActivity("http://vizZzion.org", source, "VizZzion.org");
        } else if (info->name() == "Vacation Planning") {
            connectToActivity("http://seashepherd.org", source, "Seashepherd dot Org");
        }
    }
}

void FirstRun::connectToActivity(const QString &resourceUrl, const QString &activityId, const QString &description)
{
    Nepomuk::Resource fileRes(resourceUrl);
    QUrl typeUrl;
    kError() << "Adding resource " << description << " [" << resourceUrl << "] to acivity " << activityId;
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

    Nepomuk::Resource acRes("activities://" + activityId);
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