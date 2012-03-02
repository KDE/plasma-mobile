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

#include <soprano/vocabulary.h>
#include <Nepomuk/Resource>
#include <Nepomuk/Tag>
#include <Nepomuk/Variant>

#include <nepomuk/simpleresource.h>
#include <nepomuk/simpleresourcegraph.h>
#include <nepomuk/storeresourcesjob.h>
#include <nepomuk/datamanagement.h>

#include <Nepomuk/Vocabulary/NDO>
#include <Nepomuk/Vocabulary/NFO>
#include <Nepomuk/Vocabulary/NIE>
#include <Nepomuk/Vocabulary/NUAO>

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
    Nepomuk::SimpleResource remoteFile;
    remoteFile.addType(Nepomuk::Vocabulary::NFO::RemoteDataObject());
    remoteFile.addType(Nepomuk::Vocabulary::NFO::WebDataObject());
    remoteFile.addProperty(Nepomuk::Vocabulary::NIE::url(), d->remoteUrl);

    Nepomuk::SimpleResource file;
    file.addType(Nepomuk::Vocabulary::NFO::FileDataObject());
    file.addProperty(Nepomuk::Vocabulary::NIE::url(), d->localUrl);
    file.addProperty(Nepomuk::Vocabulary::NDO::copiedFrom(), remoteFile);

    Nepomuk::SimpleResource website;
    website.addType(Nepomuk::Vocabulary::NFO::HtmlDocument());
    website.addType(Nepomuk::Vocabulary::NFO::WebDataObject());
    website.addProperty(Nepomuk::Vocabulary::NIE::url(), d->remoteUrl);

    // Record the download as event
    QDateTime dt = QDateTime::currentDateTime();
    Nepomuk::SimpleResource event;
    event.addType(Nepomuk::Vocabulary::NDO::DownloadEvent());
    event.addProperty(Nepomuk::Vocabulary::NUAO::start(), dt);
    event.addProperty(Nepomuk::Vocabulary::NUAO::end(), dt);
    event.addProperty(Nepomuk::Vocabulary::NUAO::involves(), file);
    event.addProperty(Nepomuk::Vocabulary::NDO::referrer(), website);

    //kDebug() << "storing Nepomuk meta: " << d->remoteUrl << "  " << d->localUrl;
    // Store these resources
    Nepomuk::SimpleResourceGraph graph;
    graph << remoteFile << file << website << event;
    KJob* job = Nepomuk::storeResources(graph);
    connect(job, SIGNAL(finished(KJob*)), this, SLOT(storeResourcesFinished(KJob*)));

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

    //kDebug() << "Sucessfully pushed the data";
}

#include "nepomukhelper.moc"
