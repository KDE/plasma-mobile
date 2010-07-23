/***************************************************************************
 *   Copyright 2010 Alexis Menard <menard@kde.org>                         *
 *   Copyright 2010 Artur Duque de Souza <asouza@kde.org>                  *
 *   Copyright 2010 Marco Martin <mart@kde.org>                            *
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

//own
#include "mobiledesktop.h"
#include "appletscontainer.h"
#include "appletsview.h"

//Qt
#include <QtGui/QGraphicsLinearLayout>
#include <QtGui/QGraphicsSceneDragDropEvent>

//KDE
#include <KDebug>
#include <Plasma/Corona>
#include <Plasma/ScrollWidget>

using namespace Plasma;

MobileDesktop::MobileDesktop(QObject *parent, const QVariantList &args)
    : Containment(parent, args)
{
    setHasConfigurationInterface(false);
    kDebug() << "!!! loading mobile desktop";
    setContainmentType(Containment::CustomContainment);
}

MobileDesktop::~MobileDesktop()
{
}

void MobileDesktop::init()
{
    Containment::init();

    m_appletsView = new AppletsView(this);
    m_appletsView->setVerticalScrollBarPolicy(Qt::ScrollBarAlwaysOff);
    m_appletsView->setHorizontalScrollBarPolicy(Qt::ScrollBarAlwaysOff);
    QGraphicsLinearLayout *lay = new QGraphicsLinearLayout(this);
    lay->setContentsMargins(0,0,0,0);
    setContentsMargins(0,0,0,0);
    m_container = new AppletsContainer(m_appletsView, this);
    m_appletsView->setAppletsContainer(m_container);
    lay->addItem(m_appletsView);

    connect(this, SIGNAL(appletAdded(Plasma::Applet*, QPointF)),
            m_container, SLOT(layoutApplet(Plasma::Applet*, QPointF)));
    connect(this, SIGNAL(appletRemoved(Plasma::Applet*)),
            m_container, SLOT(appletRemoved(Plasma::Applet*)));
    
    setAcceptsHoverEvents(false);
    setFlag(QGraphicsItem::ItemSendsGeometryChanges, false);
    setFlag(QGraphicsItem::ItemUsesExtendedStyleOption, false);
}

void MobileDesktop::constraintsEvent(Plasma::Constraints constraints)
{
    if (constraints & Plasma::SizeConstraint) {
        m_appletsView->setSnapSize(m_appletsView->size());
    }

    if (constraints & Plasma::StartupCompletedConstraint) {
        m_container->completeStartup();
    }
}

//They all have to be reimplemented in order to accept them
void MobileDesktop::dragEnterEvent(QGraphicsSceneDragDropEvent *event)
{
    Containment::dragEnterEvent(event);
}

void MobileDesktop::dragLeaveEvent(QGraphicsSceneDragDropEvent *event)
{
    Containment::dragLeaveEvent(event);
}

void MobileDesktop::dragMoveEvent(QGraphicsSceneDragDropEvent *event)
{
    Containment::dragMoveEvent(event);
    event->accept();
}

void MobileDesktop::dropEvent(QGraphicsSceneDragDropEvent *event)
{
    Containment::dropEvent(event);
    event->accept();
}


K_EXPORT_PLASMA_APPLET(mobiledesktop, MobileDesktop)

#include "mobiledesktop.moc"
