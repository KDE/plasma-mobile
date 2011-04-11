/*
   This file is part of the Nepomuk KDE project.
   Copyright (C) 2011 Sebastian Trueg <trueg@kde.org>

   This library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 2.1 of the License, or (at your option) version 3, or any
   later version accepted by the membership of KDE e.V. (or its
   successor approved by the membership of KDE e.V.), which shall
   act as a proxy defined in Section 6 of version 3 of the license.

   This library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Lesser General Public License for more details.

   You should have received a copy of the GNU Lesser General Public
   License along with this library.  If not, see <http://www.gnu.org/licenses/>.
*/

#ifndef RECOMMENDATION_H
#define RECOMMENDATION_H

#include <QtCore/QObject>
#include <QMetaType>

namespace Nepomuk {
class Resource;
}

namespace Contour {
class RecommendationAction;


class Recommendation : public QObject
{
    Q_OBJECT

public:
    Recommendation();
    ~Recommendation();

    //Nepomuk::Resource resource() const;
    QList<RecommendationAction*> actions() const;
    void setActions(QList<Contour::RecommendationAction *>);
    QString name() const;
    void setName(const QString &name);
    qreal relevance() const;
    void setRelevance(qreal relevance);

private:
    class Private;
    Private* const d;
};
}

Q_DECLARE_METATYPE(Contour::Recommendation*)
Q_DECLARE_METATYPE(QList<Contour::Recommendation*>)

#endif
