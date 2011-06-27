/*
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

#include "recommendationjob.h"

#include <KDebug>

#include <recommendationsclient.h>

RecommendationJob::RecommendationJob(Contour::RecommendationsClient *client,
                                     Contour::Recommendation rec,
                                     const QString &operation,
                                     QMap<QString, QVariant> &parameters,
                                     QObject *parent)
    : ServiceJob(parent->objectName(), operation, parameters, parent),
      m_recommendationsClient(client),
      m_rec(rec)
{
}

RecommendationJob::~RecommendationJob()
{
}

void RecommendationJob::start()
{
    const QString operation = operationName();
    if (operation == "executeAction") {
        QString id = parameters().value("Id").toString();
        if (id.isEmpty()) {
            setResult(false);
            return;
        }
        m_recommendationsClient->executeAction(id);
        setResult(true);
        return;
    }

    setResult(false);
}

#include "recommendationjob.moc"
