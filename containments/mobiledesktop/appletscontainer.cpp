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

#include <QGraphicsLinearLayout>
#include <QGraphicsSceneResizeEvent>
#include <QTimer>


#include <Plasma/Applet>
#include <Plasma/Containment>

using namespace Plasma;

AppletsContainer::AppletsContainer(QGraphicsItem *parent, Plasma::Containment *containment)
 : QGraphicsWidget(parent),
   m_containment(containment)
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
    relayout();
}

void AppletsContainer::relayout()
{
    const int squareSize = 400;
    int columns = qMax(1, (int)size().width() / squareSize);

    int i = 0;
    foreach (Plasma::Applet *applet, m_containment->applets()) {
        QSizeF appletSize = applet->effectiveSizeHint(Qt::PreferredSize);
        appletSize = appletSize.boundedTo(QSizeF(squareSize, squareSize));
        applet->setGeometry((i%columns)*squareSize, (i/columns)*squareSize, appletSize.width(), appletSize.height());
        i++;
    }
}

void AppletsContainer::resizeEvent(QGraphicsSceneResizeEvent *event)
{
    if (!m_relayoutTimer->isActive()) {
        m_relayoutTimer->start(300);
    }
}

#include "appletscontainer.moc"

