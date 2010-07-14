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

//Qt
#include <QtGui/QGraphicsLinearLayout>

//KDE
#include <KDebug>
#include <Plasma/Corona>

using namespace Plasma;

MobileDesktop::MobileDesktop(QObject *parent, const QVariantList &args)
    : Containment(parent, args)
{
    setHasConfigurationInterface(false);
    kDebug() << "!!! loading mobile desktop";
    // At some point it has to be a custom constainment
    //setContainmentType(Containment::CustomContainment);
}

MobileDesktop::~MobileDesktop()
{
}

void MobileDesktop::init()
{
    Containment::init();

    QGraphicsLinearLayout *lay = new QGraphicsLinearLayout(this);
    m_container = new AppletsContainer(this);
    lay->addItem(m_container);

    connect(this, SIGNAL(appletAdded(Plasma::Applet*,QPointF)),
            m_container, SLOT(layoutApplet(Plasma::Applet*,QPointF)));
    
    setAcceptsHoverEvents(false);
    setFlag(QGraphicsItem::ItemSendsGeometryChanges, false);
    setFlag(QGraphicsItem::ItemUsesExtendedStyleOption, false);
}

void MobileDesktop::constraintsEvent(Plasma::Constraints constraints)
{
    if (constraints & Plasma::StartupCompletedConstraint) {
        
    }
}

K_EXPORT_PLASMA_APPLET(mobiledesktop, MobileDesktop)

#include "mobiledesktop.moc"
