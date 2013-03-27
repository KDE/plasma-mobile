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

#ifndef RECOMMENDATION_SERVICE_H
#define RECOMMENDATION_SERVICE_H

#include "RecommendationsEngine.h"
#include "RecommendationItem.h"

#include <Plasma/Service>
#include <Plasma/ServiceJob>


using namespace Plasma;

namespace Contour {

class RecommendationService : public Plasma::Service
{
    Q_OBJECT

public:
    RecommendationService(const Contour::RecommendationItem & rec, QObject * parent = 0);
    ServiceJob * createJob(const QString &operation, QMap < QString, QVariant > & parameters);

private:
    QString m_engine, m_id;
};

}

#endif
