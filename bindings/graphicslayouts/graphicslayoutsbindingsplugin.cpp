/*
 *   Copyright 2009 by Alan Alpert <alan.alpert@nokia.com>
 *   Copyright 2010 by Ménard Alexis <menard@kde.org>
 *   Copyright 2010 by Marco Martin <mart@kde.org>

 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2, or
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

#include "graphicslayoutsbindingsplugin.h"

#include <QtDeclarative/qdeclarative.h>

#include "gridlayout.h"
#include "linearlayout.h"


void GraphicsLayoutsBindingsPlugin::registerTypes(const char *uri)
{
    Q_ASSERT(uri == QLatin1String("org.kde.plasma.graphicslayouts"));

    qmlRegisterInterface<QGraphicsLayoutItem>("QGraphicsLayoutItem");
    qmlRegisterInterface<QGraphicsLayout>("QGraphicsLayout");
    qmlRegisterType<GraphicsLinearLayoutStretchItemObject>(uri,4,7,"QGraphicsLinearLayoutStretchItem");
    qmlRegisterType<GraphicsLinearLayoutObject>(uri,4,7,"QGraphicsLinearLayout");
    qmlRegisterType<GraphicsGridLayoutObject>(uri,4,7,"QGraphicsGridLayout");
}


#include "graphicslayoutsbindingsplugin.moc"

