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

#include <QTimer>
#include <QGraphicsSceneMouseEvent>
#include <QPainter>

#include <KGlobalSettings>

#include <Plasma/Applet>
#include <Plasma/Containment>

AppletsView::AppletsView(QGraphicsItem *parent)
    : Plasma::ScrollWidget(parent),
      m_movingApplets(false)
{
    m_moveTimer = new QTimer(this);
    m_moveTimer->setSingleShot(true);
    connect(m_moveTimer, SIGNAL(timeout()), this, SLOT(moveTimerTimeout()));
}

AppletsView::~AppletsView()
{
}

void AppletsView::setAppletsContainer(AppletsContainer *appletsContainer)
{
    m_appletsContainer = appletsContainer;
    setWidget(appletsContainer);
}

AppletsContainer *AppletsView::appletsContainer() const
{
    return m_appletsContainer;
}

void AppletsView::moveTimerTimeout()
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
        m_moveTimer->start(3000);
    } else if (event->type() == QEvent::GraphicsSceneMouseMove) {
        QGraphicsSceneMouseEvent *me = static_cast<QGraphicsSceneMouseEvent *>(event);

        if (m_movingApplets) {
            if (!m_draggingApplet) {
                foreach (Plasma::Applet *applet, m_appletsContainer->m_containment->applets()) {
                    if (applet == watched || applet->isAncestorOf(watched)) {
                        applet->raise();
                        m_draggingApplet = applet;
                        break;
                    }
                }
            }
            if (m_draggingApplet) {
                const QPointF difference(me->scenePos() - me->lastScenePos());
                m_draggingApplet.data()->moveBy(difference.x(), difference.y());
                return true;
            }
        } else {
            if (QPointF(me->buttonDownScenePos(me->button()) - me->scenePos()).manhattanLength() > KGlobalSettings::dndEventDelay()*2) {
                m_movingApplets = false;
                update();
                m_moveTimer->stop();
            }
        }
    } else if (event->type() == QEvent::GraphicsSceneMouseRelease) {
        if (m_movingApplets && m_draggingApplet) {
            m_appletsContainer->relayoutApplet(m_draggingApplet.data(), m_draggingApplet.data()->geometry().center());
            m_movingApplets = false;
            m_draggingApplet.clear();
            m_moveTimer->stop();
            update();
        }
        QGraphicsSceneMouseEvent *me = static_cast<QGraphicsSceneMouseEvent *>(event);
        if (QPointF(me->buttonDownScenePos(me->button()) - me->scenePos()).manhattanLength() < KGlobalSettings::dndEventDelay()*2) {
            foreach (Plasma::Applet *applet, m_appletsContainer->m_containment->applets()) {
                if (applet == watched || applet->isAncestorOf(watched)) {
                    m_appletsContainer->setCurrentApplet(applet);
                    break;
                }
            }
        }
    }
    if (!m_appletsContainer->m_currentApplet.data()  || !m_appletsContainer->m_currentApplet.data()->isAncestorOf(watched)) {
        Plasma::ScrollWidget::sceneEventFilter(watched, event);
        return true;
    }

    return Plasma::ScrollWidget::sceneEventFilter(watched, event);
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

