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


#include <Plasma/Applet>
#include <Plasma/Containment>

using namespace Plasma;

AppletsContainer::AppletsContainer(QGraphicsItem *parent)
 : QGraphicsWidget(parent)
{
    m_layout = new QGraphicsLinearLayout(this);
    m_layout->addStretch();
}

AppletsContainer::~AppletsContainer()
{
}


void AppletsContainer::layoutApplet(Plasma::Applet* applet, const QPointF &pos)
{
    kDebug()<<"Applet added:"<<applet->name();
    applet->setParentItem(this);
    QGraphicsLinearLayout *lay = new QGraphicsLinearLayout(Qt::Vertical);
    lay->addStretch();
    lay->addItem(applet);
    lay->addStretch();
    m_layout->insertItem(m_layout->count(), lay);
}


#include "appletscontainer.moc"

