/*
 *   Copyright (C) 2011 Marco Martin <mart@kde.org>
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

#ifndef RECOMMENDATION_ITEM_H_
#define RECOMMENDATION_ITEM_H_

#include <QObject>
#include <QString>
#include <QtDBus/QDBusArgument>

namespace Contour {

class RecommendationItem: public QObject {
public:
    RecommendationItem();
    RecommendationItem(const RecommendationItem & source);
    RecommendationItem & operator = (const RecommendationItem & source);

    qreal score;
    QString title;
    QString description;
    QString icon;

    QString engine;
    QString id;

};

} // namespace Contour

Q_DECLARE_METATYPE(Contour::RecommendationItem)
Q_DECLARE_METATYPE(QList<Contour::RecommendationItem>)

QDBusArgument & operator << (QDBusArgument & arg, const Contour::RecommendationItem);
const QDBusArgument & operator >> (const QDBusArgument & arg, Contour::RecommendationItem & rec);

#endif // RECOMMENDATION_ITEM_H_
