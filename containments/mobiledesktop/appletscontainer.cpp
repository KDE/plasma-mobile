/////////////////////////////////////////////////////////////////////////
// appletscontainer.cpp                                                //
//                                                                     //
// Copyright 2010 by Marco Martin <mart@kde.org>                       //
//                                                                     //
// This library is free software; you can redistribute it and/or       //
// modify it under the terms of the GNU Lesser General Public          //
// License as published by the Free Software Foundation; either        //
// version 2.1 of the License, or (at your option) any later version.  //
//                                                                     //
// This library is distributed in the hope that it will be useful,     //
// but WITHOUT ANY WARRANTY; without even the implied warranty of      //
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU   //
// Lesser General Public License for more details.                     //
//                                                                     //
// You should have received a copy of the GNU Lesser General Public    //
// License along with this library; if not, write to the Free Software //
// Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA       //
// 02110-1301  USA                                                     //
/////////////////////////////////////////////////////////////////////////

#include "appletscontainer.h"
#include "appletsoverlay.h"

#include <cmath>

#include <QGraphicsLinearLayout>
#include <QGraphicsSceneResizeEvent>
#include <QTimer>

#include <KIconLoader>

#include <Plasma/Applet>
#include <Plasma/Containment>

using namespace Plasma;

AppletsContainer::AppletsContainer(QGraphicsItem *parent, Plasma::Containment *containment)
 : QGraphicsWidget(parent),
   m_containment(containment),
   m_appletsOverlay(0)
{
    m_relayoutTimer = new QTimer(this);
    m_relayoutTimer->setSingleShot(true);
    connect(m_relayoutTimer, SIGNAL(timeout()), this, SLOT(relayout()));
}

AppletsContainer::~AppletsContainer()
{
}


void AppletsContainer::layoutApplet(Plasma::Applet* applet, const QPointF &pos)
{
    applet->setParentItem(this);
    applet->lower();
    relayout();
}

void AppletsContainer::relayout()
{
    const int squareSize = 350;
    int columns = qMax(1, (int)m_containment->size().width() / squareSize);
    int rows = qMax(1, (int)m_containment->size().height() / squareSize);
    const QSizeF maximumAppletSize(m_containment->size().width()/columns, m_containment->size().height()/rows);

    int i = 0;
    foreach (Plasma::Applet *applet, m_containment->applets()) {
        if (applet == m_currentApplet.data()) {
            i++;
            continue;
        }
        QSizeF appletSize = applet->effectiveSizeHint(Qt::PreferredSize);
        appletSize = appletSize.boundedTo(maximumAppletSize - QSize(0, 70));
        appletSize = appletSize.expandedTo(QSize(250, 250));
        QSizeF offset(QSizeF(maximumAppletSize - appletSize)/2);

        if ((m_containment->applets().count() - i < columns)  && ((i+1)%columns != 0)) {
            offset.rwidth() += ((i+1)%columns * maximumAppletSize.width())/2;
        }

        applet->setGeometry((i%columns)*maximumAppletSize.width() + offset.width(), (i/columns)*maximumAppletSize.height() + offset.height(), appletSize.width(), appletSize.height());
        i++;
    }
    resize(size().width(), (ceil((qreal)m_containment->applets().count()/columns))*maximumAppletSize.height());
}

void AppletsContainer::resizeEvent(QGraphicsSceneResizeEvent *event)
{
    if (!qFuzzyCompare(event->oldSize().width(), event->newSize().width()) && !m_relayoutTimer->isActive()) {
        m_relayoutTimer->start(300);
    }

    syncOverlayGeometry();
}

void AppletsContainer::setAppletsOverlayVisible(const bool visible)
{
    if (visible) {
        if (!m_appletsOverlay) {
            m_appletsOverlay = new AppletsOverlay(this);
            connect(m_appletsOverlay, SIGNAL(closeRequested()), this, SLOT(hideAppletsOverlay()));
        }

        syncOverlayGeometry();
        m_appletsOverlay->setZValue(2000);
    }

    m_appletsOverlay->setVisible(visible);
}

bool AppletsContainer::isAppletsOverlayVisible() const
{
    return m_appletsOverlay && m_appletsOverlay->isVisible();
}

void AppletsContainer::hideAppletsOverlay()
{
    setAppletsOverlayVisible(false);
    setCurrentApplet(0);
}

void AppletsContainer::setCurrentApplet(Plasma::Applet *applet)
{
    if (m_currentApplet.data() == applet) {
        return;
    }


    if (m_currentApplet) {
        m_currentApplet.data()->lower();
    }

    m_currentApplet = applet;

    //FIXME: can be done more efficiently
    relayout();

    if (applet) {
        setAppletsOverlayVisible(true);
        m_currentApplet.data()->raise();
        m_currentApplet.data()->setZValue(qMax(applet->zValue(), (qreal)2100));
        m_appletsOverlay->setZValue(qMax(applet->zValue()-1, (qreal)2000));
        syncOverlayGeometry();
    } else {
        setAppletsOverlayVisible(false);
    }

}

Plasma::Applet *AppletsContainer::currentApplet() const
{
    return m_currentApplet.data();
}

void AppletsContainer::syncOverlayGeometry()
{
    if (m_currentApplet) {
        const int margin = KIconLoader::SizeHuge;

        m_currentApplet.data()->setGeometry(mapFromItem(m_containment, m_containment->boundingRect()).boundingRect().adjusted(margin, margin/2, -margin, -margin/2));
    }

    if (m_appletsOverlay) {
        m_appletsOverlay->setGeometry(mapFromItem(m_containment, m_containment->boundingRect()).boundingRect());
    }
}

#include "appletscontainer.moc"

