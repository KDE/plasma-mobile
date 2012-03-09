/*
 * Copyright 2009 Chani Armitage <chani@kde.org>
 * Copyright 2011 Marco Martin <mart@kde.org>
 * Copyright 2011 Sebastian Kügler <sebas@kde.org>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Library General Public License version 2 as
 * published by the Free Software Foundation
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details
 *
 * You should have received a copy of the GNU Library General Public
 * License along with this program; if not, write to the
 * Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#include "metadatajob.h"

#include <Nepomuk/Query/Query>
#include <Nepomuk/Resource>
#include <Nepomuk/Variant>

#include <soprano/vocabulary.h>

#include "bookmark.h"

#include <kdebug.h>

#include <KDE/KActivities/Consumer>

MetadataJob::MetadataJob(KActivities::Consumer *consumer, const QString &resourceUrl, const QString &operation, QMap<QString, QVariant> &parameters, QObject *parent)
    : ServiceJob(parent->objectName(), operation, parameters, parent),
      m_resourceUrl(resourceUrl),
      m_activityConsumer(consumer)
{
}

MetadataJob::~MetadataJob()
{
}

void MetadataJob::start()
{
    const QString operation = operationName();
    const QString activityUrl = parameters()["ActivityUrl"].toString();
    QString resourceUrl = parameters()["ResourceUrl"].toString();
    if (resourceUrl.isEmpty()) {
        resourceUrl = m_resourceUrl;
    }

    kDebug() << "starting operation" << operation << "on the resource" << m_resourceUrl << "and activity" << activityUrl;

    if (operation == "connectToActivity") {
        QString activityUrl = parameters()["ActivityUrl"].toString();
        if (activityUrl.isEmpty()) {
            activityUrl = m_activityConsumer->currentActivity();
        }

        Nepomuk::Resource fileRes(resourceUrl);
        KActivities::Info *info = new KActivities::Info(activityUrl);
        QUrl typeUrl;

        //Bookmark?
        if (QUrl(resourceUrl).scheme() == "http") {
            typeUrl = QUrl("http://www.semanticdesktop.org/ontologies/2007/03/22/nfo#Bookmark");
            fileRes.addType(typeUrl);
            fileRes.setDescription(resourceUrl);
            fileRes.setProperty(QUrl::fromEncoded("http://www.semanticdesktop.org/ontologies/2007/03/22/nfo#bookmarks"), resourceUrl);
        } else if (resourceUrl.endsWith(".desktop")) {
            typeUrl = QUrl("http://www.semanticdesktop.org/ontologies/2007/03/22/nfo#Application");
            fileRes.addType(typeUrl);
            KService::Ptr service = KService::serviceByDesktopPath(QUrl(resourceUrl).path());
            if (service) {
                fileRes.setLabel(service->name());
                fileRes.addSymbol(service->icon());
            }
        }

        info->linkResource(resourceUrl);
        info->deleteLater();
        setResult(true);
        return;

    } else if (operation == "disconnectFromActivity") {
        QString activityUrl = parameters()["ActivityUrl"].toString();
        activityUrl = m_activityConsumer->currentActivity();

        QString resourceUrl = parameters()["ResourceUrl"].toString();

        KActivities::Info *info = new KActivities::Info(activityUrl);
        info->unlinkResource(resourceUrl);
        info->deleteLater();

        setResult(true);
        return;

    } else if (operation == "rate") {
        int rating = parameters()["Rating"].toInt();
        Nepomuk::Resource fileRes(resourceUrl);
        fileRes.setRating(rating);
        setResult(true);
        return;

    } else if (operation == "addBookmark") {
        const QString url = parameters()["Url"].toString();
        Nepomuk::Bookmark b(url);

        QUrl u(url);
        if (u.isValid()) {
            b.setBookmarks( url );
            setResult(true);
        } else {
            setResult(false);
        }
        return;

    } else if (operation == "remove") {
        Nepomuk::Resource b(resourceUrl);
        kDebug() << "Removing resource TYPE: " << b.resourceType() << "url" << resourceUrl;
        b.remove();
        setResult(true);
        return;
    }

    setResult(false);
}

#include "metadatajob.moc"
