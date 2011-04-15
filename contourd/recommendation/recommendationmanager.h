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

#ifndef RECOMMENDATIONMANAGER_H
#define RECOMMENDATIONMANAGER_H

#include <QObject>
#include <QtCore/QList>

#include "dbusoperators.h"

namespace Contour {

class Recommendation;

class RecommendationManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QList<Contour::Recommendation*> recommendations READ recommendations)

public:
    RecommendationManager(QObject* parent = 0);
    ~RecommendationManager();

    QList<Recommendation*> recommendations() const;

public Q_SLOTS:
    void executeAction(const QString& actionId);

Q_SIGNALS:
    void recommendationsChanged();

private:
    class Private;
    Private* const d;

    Q_PRIVATE_SLOT(d, void _k_locationChanged(QList<QLandmark>))
    Q_PRIVATE_SLOT(d, void _k_currentActivityChanged(QString))
    Q_PRIVATE_SLOT(d, void _k_newResults(QList<Nepomuk::Query::Result>))
    Q_PRIVATE_SLOT(d, void _k_queryFinished())
};

}


#endif
