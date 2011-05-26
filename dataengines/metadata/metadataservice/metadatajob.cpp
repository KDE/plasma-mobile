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

#include <kactivityconsumer.h>

MetadataJob::MetadataJob(KActivityConsumer *consumer, const QString &id, const QString &operation, QMap<QString, QVariant> &parameters, QObject *parent) :
    ServiceJob(parent->objectName(), operation, parameters, parent),
    m_id(id),
    m_activityConsumer(consumer)
{
}

MetadataJob::~MetadataJob()
{
}

void MetadataJob::start()
{
    const QString operation = operationName();
    const QString resourceUrl = parameters()["ResourceUrl"].toString();
    const QString activityUrl = parameters()["ActivityUrl"].toString();

    kDebug() << "starting operation" << operation << "on the resource" << resourceUrl << "and activity" << activityUrl;

    if (operation == "connectToActivity") {
        const QString resourceUrl = parameters()["ResourceUrl"].toString();
        QString activityUrl = parameters()["ActivityUrl"].toString();
        if (activityUrl.isEmpty()) {
            activityUrl = m_activityConsumer->currentActivity();
        }

        Nepomuk::Resource fileRes(resourceUrl);
        Nepomuk::Resource acRes("activities://" + activityUrl);

        acRes.addProperty(Soprano::Vocabulary::NAO::isRelated(), fileRes);
        setResult(true);
        return;
    } else if (operation == "disconnectFromActivity") {
        const QString resourceUrl = parameters()["ResourceUrl"].toString();
        QString activityUrl = parameters()["ActivityUrl"].toString();
        activityUrl = m_activityConsumer->currentActivity();

        QString url = parameters()["ResourceUrl"].toString();

        Nepomuk::Resource fileRes(resourceUrl);
        Nepomuk::Resource acRes("activities://" + activityUrl);

        acRes.removeProperty(Soprano::Vocabulary::NAO::isRelated(), fileRes);
        setResult(true);
        return;
    } else if (operation == "rate") {
        int rating = parameters()["Rating"].toInt();
        kDebug() << "Rating: " << rating << resourceUrl;
        Nepomuk::Resource fileRes(resourceUrl);
        fileRes.setRating(rating);
        setResult(true);
        return;
    } else if (operation == "addBookmark") {
        const QString url = parameters()["Url"].toString();
        Nepomuk::Bookmark b;
        b.setLabel("Active Bookmark!");
        b.setDescription(url);
        QUrl u(url);
        if (u.isValid()) {
            b.setBookmarks( url );
            setResult(true);
        } else {
            setResult(false);
        }
        return;
    } else if (operation == "remove") {
        const QString url = parameters()["ResourceUrl"].toString();
        Nepomuk::Resource b(url);
        kDebug() << "Removing resource TYPE: " << b.resourceType() << "url" << url;
        b.remove();
        setResult(true);
        return;
    }

    setResult(false);
}

#include "metadatajob.moc"
