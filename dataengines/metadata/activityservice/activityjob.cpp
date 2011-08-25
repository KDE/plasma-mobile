/*
 * Copyright 2009 Chani Armitage <chani@kde.org>
 * Copyright 2011 Marco Martin <mart@kde.org>
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

#include "activityjob.h"

#include <Nepomuk/Query/Query>
#include <Nepomuk/Resource>
#include <Nepomuk/Variant>

#include <soprano/vocabulary.h>

#include <kdebug.h>

ActivityJob::ActivityJob(const QString &id, const QString &operation, QMap<QString, QVariant> &parameters, QObject *parent) :
    ServiceJob(parent->objectName(), operation, parameters, parent),
    m_id(id)
{
}

ActivityJob::~ActivityJob()
{
}

void ActivityJob::start()
{
    const QString operation = operationName();
    const QString resourceUrl = parameters()["ResourceUrl"].toString();
    const QString activityUrl = parameters()["ActivityUrl"].toString();

    kDebug() << "starting operation" << operation << "on the resource" << resourceUrl << "and activity" << activityUrl;

    if (operation == "addAssociation") {

        Nepomuk::Resource fileRes(resourceUrl);
        Nepomuk::Resource acRes("activities://" + activityUrl);
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
                fileRes.setSymbols(QStringList() << service->icon());
            }
        }

        acRes.addProperty(Soprano::Vocabulary::NAO::isRelated(), fileRes);
        setResult(true);
        return;
    } else if (operation == "removeAssociation") {
        QString url = parameters()["ResourceUrl"].toString();

        Nepomuk::Resource fileRes(resourceUrl);
        Nepomuk::Resource acRes("activities://" + activityUrl);

        acRes.removeProperty(Soprano::Vocabulary::NAO::isRelated(), fileRes);
        setResult(true);
        return;
    }
    setResult(false);
}

#include "activityjob.moc"
