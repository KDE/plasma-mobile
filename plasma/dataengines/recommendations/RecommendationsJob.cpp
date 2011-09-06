/*
 * Copyright (C) 2011 Marco Martin <mart@kde.org>
 * Copyright (C) 2011 Ivan Cukic <ivan.cukic(at)kde.org>
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

#include "RecommendationsJob.h"
#include "RecommendationManager.h"

#include <KDebug>

namespace Contour {

RecommendationJob::RecommendationJob(const QString & operation,
                                     const QString & engine,
                                     const QString & id,
                                     QMap < QString, QVariant > & parameters,
                                     QObject *parent)
    : ServiceJob(parent->objectName(), operation, parameters, parent)
{
    m_engine = engine;
    m_id = id;
}

RecommendationJob::~RecommendationJob()
{
}

void RecommendationJob::start()
{
    kDebug() << operationName() << parameters() << m_engine;

    if (operationName() == "executeAction") {
        QString action = parameters().value("Action").toString();

        if (m_id.isEmpty() || m_engine.isEmpty()) {
            setResult(false);
            return;
        }

        RecommendationManager::self()->executeAction(m_engine, m_id, action);

        setResult(true);
        return;
    }

    setResult(false);
}

} // namespace Contour

#include "RecommendationsJob.moc"
