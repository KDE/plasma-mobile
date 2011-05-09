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

#include <kactivityconsumer.h>
#include <kdebug.h>

ActivityJob::ActivityJob(KActivityConsumer *controller, const QString &id, const QString &operation, QMap<QString, QVariant> &parameters, QObject *parent) :
    ServiceJob(parent->objectName(), operation, parameters, parent),
    m_activityConsumer(controller),
    m_id(id)
{
    m_id = m_id.replace(QRegExp("&query=.*"), "");
}

ActivityJob::~ActivityJob()
{
}

void ActivityJob::start()
{
    const QString operation = operationName();
    if (operation == "addAssociation") {

        Nepomuk::Resource fileRes(m_id);
        Nepomuk::Resource acRes("activities://" + m_activityConsumer->currentActivity());
kWarning()<<"AAAAAA"<<m_id;
        acRes.addProperty(Soprano::Vocabulary::NAO::isRelated(), fileRes);
        setResult(true);
        return;
    } else if (operation == "removeAssociation") {
        QString url = parameters()["ResourceUrl"].toString();

        Nepomuk::Resource fileRes(m_id);
        Nepomuk::Resource acRes("activities://" + m_activityConsumer->currentActivity());

        acRes.removeProperty(Soprano::Vocabulary::NAO::isRelated(), fileRes);
        setResult(true);
        return;
    }
    setResult(false);
}

#include "activityjob.moc"
