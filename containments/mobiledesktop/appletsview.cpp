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

#include <KGlobalSettings>

#include <Plasma/Containment>

AppletsView::AppletsView(QGraphicsItem *parent)
    : Plasma::ScrollWidget(parent)
{
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

bool AppletsView::sceneEventFilter(QGraphicsItem *watched, QEvent *event)
{
    if (m_appletsContainer->isAppletsOverlayVisible()) {
        return false;
    }

    if (event->type() == QEvent::GraphicsSceneMousePress) {
        
    } else if (event->type() == QEvent::GraphicsSceneMouseRelease) {
        foreach (Plasma::Applet *applet, m_appletsContainer->m_containment->applets()) {
            if (applet == watched || applet->isAncestorOf(watched)) {
                m_appletsContainer->setCurrentApplet(applet);
                break;
            }
        }
    }
    if (!m_appletsContainer->m_currentApplet.data()  || !m_appletsContainer->m_currentApplet.data()->isAncestorOf(watched)) {
        Plasma::ScrollWidget::sceneEventFilter(watched, event);
        return true;
    }

    return Plasma::ScrollWidget::sceneEventFilter(watched, event);
}


#include "appletsview.moc"

