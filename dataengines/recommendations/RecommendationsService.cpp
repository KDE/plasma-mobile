/*
 *   Copyright (C) 2011 Marco Martin <mart@kde.org>
 *   Copyright (C) 2011 Ivan Cukic <ivan.cukic(at)kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2 or
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

#include "RecommendationsService.h"
#include "RecommendationsJob.h"

namespace Contour {

RecommendationService::RecommendationService(const Contour::RecommendationItem & rec, QObject * parent)
    : Plasma::Service(parent)
{
    setName("recommendations");
    m_engine = rec.engine;
    m_id     = rec.id;

    kDebug() << "Engine is this" << rec.engine << "and this item" << rec.id;
}

ServiceJob *RecommendationService::createJob(const QString & operation,
                                             QMap < QString, QVariant > & parameters)
{
    return new RecommendationJob(operation, m_engine, m_id, parameters, this);
}

} // namespace Contour

#include "RecommendationsService.moc"
