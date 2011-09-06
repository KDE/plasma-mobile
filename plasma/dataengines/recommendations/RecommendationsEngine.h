/*
 *   Copyright (C) 2010 Marco Martin <mart@kde.org>
 *   Copyright (C) 2011 Ivan Cukic <ivan.cukic@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License version 2 as
 *   published by the Free Software Foundation
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

#ifndef RECOMMENDATIONSENGINE_H
#define RECOMMENDATIONSENGINE_H

#include <QHash>
#include <QString>

#include <Plasma/DataEngine>

#include "RecommendationItem.h"

namespace Contour {

class RecommendationsEngine: public Plasma::DataEngine
{
    Q_OBJECT

public:
    RecommendationsEngine(QObject * parent, const QVariantList & args);
    ~RecommendationsEngine();

    Plasma::Service * serviceForSource(const QString &source);
    virtual void init();

protected slots:
    void updateRecommendations(const QList < Contour::RecommendationItem > & recommendations);

private:
    QHash < QString, Contour::RecommendationItem > m_recommendations;
};

}

#endif
