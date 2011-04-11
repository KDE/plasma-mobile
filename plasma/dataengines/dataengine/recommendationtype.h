/***************************************************************************
 *                                                                         *
 *   Copyright (C) 2011 Marco Martin <mart@kde.org                         *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA .        *
 ***************************************************************************/

#ifndef RECOMMENDATIONTYPE_H
#define RECOMMENDATIONTYPE_H

#include <QDBusArgument>

#include "recommendation.h"
#include "recommendationaction.h"


const QDBusArgument &operator<<(QDBusArgument &argument, const Contour::Recommendation *recommendation);
const QDBusArgument &operator>>(const QDBusArgument &argument, Contour::Recommendation *recommendation);

const QDBusArgument &operator<<(QDBusArgument &argument, const Contour::RecommendationAction *recommendationAction);
const QDBusArgument &operator>>(const QDBusArgument &argument, Contour::RecommendationAction *recommendationAction);

const QDBusArgument &operator<<(QDBusArgument &argument, const QList<Contour::Recommendation*> &recommendations);
const QDBusArgument &operator>>(const QDBusArgument &argument, QList<Contour::Recommendation *> &recommendation);

#endif
