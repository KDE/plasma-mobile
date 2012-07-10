/***************************************************************************
 *                                                                         *
 *   Copyright 2012 Sebastian Kügler <sebas@kde.org>                       *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA .        *
 ***************************************************************************/

#include "nepomukhelper.h"

#include <KJob>

#include <soprano/vocabulary.h>
#include <Nepomuk2/Resource>
#include <Nepomuk2/Tag>
#include <Nepomuk2/Variant>

//TODO: re-enable as soon we migrate to nepomuk2
//#include <nepomuk2/simpleresource.h>
//#include <nepomuk2/simpleresourcegraph.h>
//#include <nepomuk2/storeresourcesjob.h>
//#include <nepomuk2/datamanagement.h>

#include <Nepomuk2/Vocabulary/NDO>
#include <Nepomuk2/Vocabulary/NFO>
#include <Nepomuk2/Vocabulary/NIE>
#include <Nepomuk2/Vocabulary/NUAO>

#include <kactivities/consumer.h>
#include <kdebug.h>

class NepomukHelperPrivate {
public:
    QUrl localUrl;
    QUrl remoteUrl;
    KActivities::Consumer* activityConsumer;
};

NepomukHelper::NepomukHelper(QObject *parent)
    : QObject(parent)
{
    d = new NepomukHelperPrivate;
    d->activityConsumer = new KActivities::Consumer(this);

}

NepomukHelper::~NepomukHelper()
{
    delete d;
}

void NepomukHelper::storeDownloadMetaData(const KUrl &remoteUrl, const KUrl &localUrl)
{
    d->localUrl = localUrl;
    d->remoteUrl = remoteUrl;

    // Create resources for the remote and local file and website
    //TODO: use Resource again as soon migrated to Nepomuk2
    Nepomuk2::Resource remoteFile;
    remoteFile.addType(Nepomuk2::Vocabulary::NFO::RemoteDataObject());
    remoteFile.addType(Nepomuk2::Vocabulary::NFO::WebDataObject());
    remoteFile.addProperty(Nepomuk2::Vocabulary::NIE::url(), d->remoteUrl);

    Nepomuk2::Resource file;
    file.addType(Nepomuk2::Vocabulary::NFO::FileDataObject());
    file.addProperty(Nepomuk2::Vocabulary::NIE::url(), d->localUrl);
    file.addProperty(Nepomuk2::Vocabulary::NDO::copiedFrom(), remoteFile);

    Nepomuk2::Resource website;
    website.addType(Nepomuk2::Vocabulary::NFO::HtmlDocument());
    website.addType(Nepomuk2::Vocabulary::NFO::WebDataObject());
    website.addProperty(Nepomuk2::Vocabulary::NIE::url(), d->remoteUrl);

    // Record the download as event
    QDateTime dt = QDateTime::currentDateTime();
    Nepomuk2::Resource event;
    event.addType(Nepomuk2::Vocabulary::NDO::DownloadEvent());
    event.addProperty(Nepomuk2::Vocabulary::NUAO::start(), dt);
    event.addProperty(Nepomuk2::Vocabulary::NUAO::end(), dt);
    event.addProperty(Nepomuk2::Vocabulary::NUAO::involves(), file);
    event.addProperty(Nepomuk2::Vocabulary::NDO::referrer(), website);

    //kDebug() << "storing Nepomuk meta: " << d->remoteUrl << "  " << d->localUrl;
    // Store these resources
/*    Nepomuk2::ResourceGraph graph;
    graph << remoteFile << file << website << event;
    KJob* job = Nepomuk2::storeResources(graph);
    connect(job, SIGNAL(finished(KJob*)), this, SLOT(storeResourcesFinished(KJob*)));*/

    // And link the downloaded file to the currently active Activity
    QString activityId = d->activityConsumer->currentActivity();
    KActivities::Info aInfo(activityId);
    aInfo.linkResource(d->localUrl);
}

void NepomukHelper::storeResourcesFinished(KJob *job)
{
    if( job->error() ) {
        kWarning() << "Error storing metadata for download: " << job->errorString();
        return;
    }

    //kDebug() << "Successfully pushed the data";
}

#include "nepomukhelper.moc"
