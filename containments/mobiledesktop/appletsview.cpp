/*
 *   Copyright 2010 Marco Martin <mart@kde.org>
 *
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

#include "appletsview.h"
#include "dragcountdown.h"

#include <QTimer>
#include <QGraphicsSceneMouseEvent>
#include <QPainter>

#include <KGlobalSettings>

#include <Plasma/AbstractToolBox>
#include <Plasma/Applet>
#include <Plasma/Containment>

AppletsView::AppletsView(QGraphicsItem *parent)
    : Plasma::ScrollWidget(parent),
      m_movingApplets(false),
      m_scrollDown(false)
{
    m_dragCountdown = new DragCountdown(this);

    connect(m_dragCountdown, SIGNAL(dragRequested()), this, SLOT(appletDragRequested()));

    m_scrollTimer = new QTimer(this);
    m_scrollTimer->setSingleShot(false);
    connect(m_scrollTimer, SIGNAL(timeout()), this, SLOT(scrollTimeout()));

    setAlignment(Qt::AlignCenter);
}

AppletsView::~AppletsView()
{
}

void AppletsView::setAppletsContainer(AppletsContainer *appletsContainer)
{
    m_appletsContainer = appletsContainer;
    setWidget(appletsContainer);
    if (appletsContainer->orientation() == Qt::Vertical) {
        appletsContainer->setSizePolicy(QSizePolicy::Expanding, QSizePolicy::Fixed);
    } else {
        appletsContainer->setSizePolicy(QSizePolicy::Fixed, QSizePolicy::Expanding);
    }
}

AppletsContainer *AppletsView::appletsContainer() const
{
    return m_appletsContainer;
}

void AppletsView::setOrientation(const Qt::Orientation orientation)
{
    m_appletsContainer->setOrientation(orientation);
    if (m_appletsContainer->orientation() == Qt::Vertical) {
        m_appletsContainer->setSizePolicy(QSizePolicy::Expanding, QSizePolicy::Fixed);
    } else {
        m_appletsContainer->setSizePolicy(QSizePolicy::Fixed, QSizePolicy::Expanding);
    }
}

Qt::Orientation AppletsView::orientation() const
{
    return m_appletsContainer->orientation();
}

void AppletsView::appletDragRequested()
{
    m_movingApplets = true;
    update();
}

bool AppletsView::sceneEventFilter(QGraphicsItem *watched, QEvent *event)
{
    if (m_appletsContainer->isAppletsOverlayVisible()) {
        return false;
    }


    if (event->type() == QEvent::GraphicsSceneMousePress) {
        QGraphicsSceneMouseEvent *me = static_cast<QGraphicsSceneMouseEvent *>(event);

        if (!(me->buttons() & Qt::LeftButton)) {
            return Plasma::ScrollWidget::sceneEventFilter(watched, event);
        }

        Plasma::Applet *appletUnderMouse = 0;
        //find an applet to put the indicator over
        foreach (Plasma::Applet *applet, m_appletsContainer->m_containment->applets()) {
            if (applet->boundingRect().contains(applet->mapFromScene(me->scenePos()))) {
                appletUnderMouse = applet;
                break;
            }
        }

        if (appletUnderMouse) {
            //put the move indicator in the center of the VISIBLE area of the applet
            const QRectF mappedAppleRect(mapFromItem(appletUnderMouse, appletUnderMouse->boundingRect()).boundingRect().intersected(boundingRect()));

            m_dragCountdown->setPos(mappedAppleRect.center() - QPoint(m_dragCountdown->size().width()/2, m_dragCountdown->size().height()/2));
            m_dragCountdown->start(1000);
        }

        return Plasma::ScrollWidget::sceneEventFilter(watched, event);

    } else if (event->type() == QEvent::GraphicsSceneMouseMove) {
        QGraphicsSceneMouseEvent *me = static_cast<QGraphicsSceneMouseEvent *>(event);

        if (m_movingApplets) {
            if (!m_draggingApplet) {
                foreach (Plasma::Applet *applet, m_appletsContainer->m_containment->applets()) {
                    if (applet->boundingRect().contains(applet->mapFromScene(me->scenePos()))) {
                        applet->raise();
                        m_draggingApplet = applet;
                        break;
                    }
                }
            }
            if (m_draggingApplet) {
                const QPointF difference(me->scenePos() - me->lastScenePos());
                m_draggingApplet.data()->moveBy(difference.x(), difference.y());

                //put the move indicator in the center of the VISIBLE area of the applet
                const QRectF mappedAppleRect(mapFromItem(m_draggingApplet.data(), m_draggingApplet.data()->boundingRect()).boundingRect().intersected(boundingRect()));

                m_dragCountdown->setPos(mappedAppleRect.center() - QPoint(m_dragCountdown->size().width()/2, m_dragCountdown->size().height()/2));

                if (mapFromScene(me->scenePos()).y() > 3*(viewportGeometry().height()/4)) {
                    if (!m_scrollTimer->isActive()) {
                        m_scrollTimer->start(50);
                    }
                    m_scrollDown = true;
                } else if (mapFromScene(me->scenePos()).y() < (viewportGeometry().height()/4)) {
                    if (!m_scrollTimer->isActive()) {
                        m_scrollTimer->start(50);
                    }
                    m_scrollDown = false;
                } else {
                    m_scrollTimer->stop();
                }

                return true;
            } else {
                return Plasma::ScrollWidget::sceneEventFilter(watched, event);
            }
        } else {
            if (QPointF(me->buttonDownScenePos(me->button()) - me->scenePos()).manhattanLength() > KGlobalSettings::dndEventDelay()*2) {
                update();
                m_dragCountdown->stop();
            }
            return Plasma::ScrollWidget::sceneEventFilter(watched, event);
        }
    } else if (event->type() == QEvent::GraphicsSceneMouseRelease) {
        m_dragCountdown->stop();
        m_scrollTimer->stop();
        if (m_movingApplets && m_draggingApplet) {
            m_appletsContainer->relayoutApplet(m_draggingApplet.data(), m_draggingApplet.data()->geometry().center());
            m_draggingApplet.clear();
            update();
        }
        m_movingApplets = false;
    }


    return Plasma::ScrollWidget::sceneEventFilter(watched, event);
}

void AppletsView::scrollTimeout()
{
    if (!m_draggingApplet) {
        return;
    }

    if (m_scrollDown) {
        m_draggingApplet.data()->moveBy(0, 10);
        m_appletsContainer->moveBy(0, -10);
    } else {
        m_draggingApplet.data()->moveBy(0, -10);
        m_appletsContainer->moveBy(0, 10);
    }
}

void AppletsView::paint(QPainter *painter,
                       const QStyleOptionGraphicsItem *option,
                       QWidget *widget)
{
    if (!m_movingApplets) {
        return;
    }

    Q_UNUSED(widget)

    QColor color(0, 0, 0, 120);
    painter->fillRect(option->rect, color);
}

#include "appletsview.moc"

