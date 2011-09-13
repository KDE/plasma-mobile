/*
 *   Copyright (C) 2011 Ivan Cukic <ivan.cukic(at)kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License version 2,
 *   or (at your option) any later version, as published by the Free
 *   Software Foundation
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#include "RecommendationItem.h"

#include <QMetaType>

namespace Contour {

class RecommendationItemStaticInitializer {
public:
    RecommendationItemStaticInitializer()
    {
        qRegisterMetaType < Contour::RecommendationItem > ("Contour::RecommendationItem");
        qRegisterMetaType < QList < Contour::RecommendationItem > > ("QList<Contour::RecommendationItem>");
    }

    static RecommendationItemStaticInitializer _instance;

};

RecommendationItemStaticInitializer RecommendationItemStaticInitializer::_instance;

RecommendationItem::RecommendationItem()
{
}

RecommendationItem::RecommendationItem(const RecommendationItem & source)
    : QObject()
{
    score       = source.score;
    title       = source.title;
    description = source.description;
    icon        = source.icon;
    engine      = source.engine;
    id          = source.id;
}

RecommendationItem & RecommendationItem::operator = (const RecommendationItem & source)
{
    if (&source == this) {
        score       = source.score;
        title       = source.title;
        description = source.description;
        icon        = source.icon;
        engine      = source.engine;
        id          = source.id;
    }

    return *this;
}

} // namespace Contour

QDBusArgument & operator << (QDBusArgument & arg, const Contour::RecommendationItem r)
{
    arg.beginStructure();

    arg << r.engine;
    arg << r.id;

    arg << r.score;
    arg << r.title;
    arg << r.description;
    arg << r.icon;

    arg.endStructure();

    return arg;
}

const QDBusArgument & operator >> (const QDBusArgument & arg, Contour::RecommendationItem & r)
{
    arg.beginStructure();

    arg >> r.engine;
    arg >> r.id;

    arg >> r.score;
    arg >> r.title;
    arg >> r.description;
    arg >> r.icon;

    arg.endStructure();

    return arg;
}

QDebug operator << (QDebug dbg, const Contour::RecommendationItem & r)
{
    dbg << "Recommendation(" << r.score << r.id << r.title << r.description << r.icon << ")";
    return dbg.space();
}
