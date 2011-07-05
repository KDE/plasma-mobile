/*
    Copyright 2011 Marco Martin <notmart@gmail.com>

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Library General Public
    License as published by the Free Software Foundation; either
    version 2 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Library General Public License for more details.

    You should have received a copy of the GNU Library General Public License
    along with this library; see the file COPYING.LIB.  If not, write to
    the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
    Boston, MA 02110-1301, USA.
*/

#include "mouseeventlistener.h"

#include <QEvent>
#include <QGraphicsSceneMouseEvent>

#include <KDebug>

MouseEventListener::MouseEventListener(QDeclarativeItem *parent)
    : QDeclarativeItem(parent)
{
    setFiltersChildEvents(true);
    setAcceptedMouseButtons(Qt::LeftButton|Qt::RightButton|Qt::MidButton|Qt::XButton1|Qt::XButton2);
}

MouseEventListener::~MouseEventListener()
{
}

void MouseEventListener::mousePressEvent(QGraphicsSceneMouseEvent *me)
{
    QDeclarativeMouseEvent dme(me->pos().x(), me->pos().y(), me->screenPos().x(), me->screenPos().y(), me->button(), me->buttons(), me->modifiers());
    emit pressed(&dme);
}

void MouseEventListener::mouseMoveEvent(QGraphicsSceneMouseEvent *me)
{
    QDeclarativeMouseEvent dme(me->pos().x(), me->pos().y(), me->screenPos().x(), me->screenPos().y(), me->button(), me->buttons(), me->modifiers());
    emit positionChanged(&dme);
}

void MouseEventListener::mouseReleaseEvent(QGraphicsSceneMouseEvent *me)
{
    QDeclarativeMouseEvent dme(me->pos().x(), me->pos().y(), me->screenPos().x(), me->screenPos().y(), me->button(), me->buttons(), me->modifiers());
    emit released(&dme);
}

bool MouseEventListener::sceneEventFilter(QGraphicsItem *item, QEvent *event)
{
    if (!isEnabled()) {
        return true;
    }

    switch (event->type()) {
    case QEvent::GraphicsSceneMousePress: {
        QGraphicsSceneMouseEvent *me = static_cast<QGraphicsSceneMouseEvent *>(event);
        //the parent will receive events in its own coordinates
        const QPointF myPos = item->mapToItem(this, me->pos());
        QDeclarativeMouseEvent dme(myPos.x(), myPos.y(), me->screenPos().x(), me->screenPos().y(), me->button(), me->buttons(), me->modifiers());
        emit pressed(&dme);
        break;
    }
    case QEvent::GraphicsSceneMouseMove: {
        QGraphicsSceneMouseEvent *me = static_cast<QGraphicsSceneMouseEvent *>(event);
        const QPointF myPos = item->mapToItem(this, me->pos());
        QDeclarativeMouseEvent dme(myPos.x(), myPos.y(), me->screenPos().x(), me->screenPos().y(), me->button(), me->buttons(), me->modifiers());
        emit positionChanged(&dme);
        break;
    }
    case QEvent::GraphicsSceneMouseRelease: {
        QGraphicsSceneMouseEvent *me = static_cast<QGraphicsSceneMouseEvent *>(event);
        const QPointF myPos = item->mapToItem(this, me->pos());
        QDeclarativeMouseEvent dme(myPos.x(), myPos.y(), me->screenPos().x(), me->screenPos().y(), me->button(), me->buttons(), me->modifiers());
        emit released(&dme);
        break;
    }
    default:
        break;
    }

    return QDeclarativeItem::sceneEventFilter(item, event);
}

#include "mouseeventlistener.moc"

