 
/***************************************************************************
 *                                                                         *
 *   Copyright (C) 2011 Marco Martin <mart@kde.org>                        *
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

#include "recommendationtype.h"
#include <KDebug>



// Marshall the Contour::Recommendation data into a D-BUS argument
const QDBusArgument &operator<<(QDBusArgument &argument, const Contour::Recommendation *recommendation)
{
    argument.beginStructure();
    argument << recommendation->name();
    argument << recommendation->relevance();
    
    argument.beginArray();
    foreach (Contour::RecommendationAction *action, recommendation->actions()) {
        argument << action;
    }
    argument.endArray();
    
    argument.endStructure();
    return argument;
}


// Retrieve the Contour::Recommendation data from the D-BUS argument
const QDBusArgument &operator>>(const QDBusArgument &argument, Contour::Recommendation *recommendation)
{
    QString name;
    qreal relevance;
    QList<Contour::RecommendationAction*> actions;

    if (argument.currentType() == QDBusArgument::StructureType) {
        argument.beginStructure();
        //kDebug() << "begun structure";
        argument >> name;
        //kDebug() << name;
        argument >> relevance;
        //kDebug() << relevance;
        
        while (argument.currentType() == QDBusArgument::ArrayType) {
            Contour::RecommendationAction *action;
            argument >> action;
            actions << action;
        }
        
        argument.endStructure();
    }

    recommendation->setName(name);
    recommendation->setRelevance(relevance);
    recommendation->setActions(actions);

    return argument;
}


// Marshall the Contour::RecommendationAction data into a D-BUS argument
const QDBusArgument &operator<<(QDBusArgument &argument, const Contour::RecommendationAction *recommendationAction)
{
    argument.beginStructure();
    argument << recommendationAction->id();
    argument << recommendationAction->name();
    argument << recommendationAction->iconName();
    argument << recommendationAction->relevance();
    
    argument.endStructure();
    return argument;
}


// Retrieve the Contour::RecommendationAction data from the D-BUS argument
const QDBusArgument &operator>>(const QDBusArgument &argument, Contour::RecommendationAction *recommendationAction)
{
    QString id;
    QString name;
    QString iconName;
    qreal relevance;

    if (argument.currentType() == QDBusArgument::StructureType) {
        argument.beginStructure();
        //kDebug() << "begun structure";
        argument >> id;
        //kDebug() << id;
        argument >> name;
        //kDebug() << name;
        argument >> iconName;
        //kDebug() << iconName;
        argument >> relevance;
        //kDebug() << relevance;

        argument.endStructure();
    }

    recommendationAction->setId(id);
    recommendationAction->setName(name);
    recommendationAction->setIconName(name);
    recommendationAction->setRelevance(relevance);

    return argument;
}

// Marshall the QList<Contour::Recommendation> data into a D-BUS argument
const QDBusArgument &operator<<(QDBusArgument &argument, const QList<Contour::Recommendation*> &recommendations)
{
    argument.beginArray();
    foreach (Contour::Recommendation *recommendation, recommendations) {
        argument << recommendation;
    }
    argument.endArray();
    
    return argument;
}


// Retrieve the QList<Contour::Recommendation> data from the D-BUS argument
const QDBusArgument &operator>>(const QDBusArgument &argument, QList<Contour::Recommendation *> &recommendation)
{
       
    while (argument.currentType() == QDBusArgument::ArrayType) {
        Contour::Recommendation *recommendation = new Contour::Recommendation();
        argument >> recommendation;
    }

    return argument;
}
