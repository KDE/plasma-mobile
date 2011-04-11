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

#include "recommendationaction.h"

class Contour::RecommendationAction::Private
{
public:
    QString id;
    QString name;
    QString iconName;
    qreal relevance;
};

Contour::RecommendationAction::RecommendationAction(QObject *parent)
    : QAction(parent),
      d(new Private())
{
}

Contour::RecommendationAction::~RecommendationAction()
{
    delete d;
}

QString Contour::RecommendationAction::id() const
{
    return d->id;
}

void Contour::RecommendationAction::setId(const QString &id)
{
    d->id = id;
}

QString Contour::RecommendationAction::name() const
{
    return d->name;
}

void Contour::RecommendationAction::setName(const QString &name)
{
    d->name = name;
}

void Contour::RecommendationAction::setIconName(const QString &name)
{
    d->iconName = name;
}

QString Contour::RecommendationAction::iconName() const
{
    return d->iconName;
}

qreal Contour::RecommendationAction::relevance() const
{
    return d->relevance;
}

void Contour::RecommendationAction::setRelevance(qreal relevance)
{
    d->relevance = relevance;
}

#include "recommendationaction.moc"
