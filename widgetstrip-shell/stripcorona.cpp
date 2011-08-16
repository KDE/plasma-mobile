/***************************************************************************
 *   Copyright 2009 Marco Martin <mart@kde.org>                            *
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

#include "stripcorona.h"

#include <QGraphicsView>

static const char *DEFAULT_CONTAINMENT = "org.kde.appletstrip";

StripCorona::StripCorona(QObject *parent)
    : Plasma::Corona(parent)
{
}

StripCorona::~StripCorona()
{

}


QRect StripCorona::screenGeometry(int id) const
{
    Q_UNUSED(id);
    QGraphicsView *v = views().value(0);
    if (v) {
        return QRect(QPoint(0, 0), v->size());
    }

    return sceneRect().toRect();
}


void StripCorona::loadDefaultLayout()
{
    Plasma::Containment* c = addContainmentDelayed(DEFAULT_CONTAINMENT);

    if (!c) {
        return;
    }

    c->init();

    c->setScreen(0);

    c->setWallpaper("image", "SingleImage");
    c->setFormFactor(Plasma::Planar);
    c->updateConstraints(Plasma::StartupCompletedConstraint);
    c->flushPendingConstraintsEvents();

    // stacks all the containments at the same place
    c->setPos(0, 0);

    emit containmentAdded(c);

    c->addApplet("org.kde.news-qml");
    c->addApplet("org.kde.analogclock");

    requestConfigSync();
}


#include "stripcorona.moc"

