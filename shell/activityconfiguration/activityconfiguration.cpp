/***************************************************************************
 *   Copyright 2010 Alexis Menard <menard@kde.org>                         *
 *   Copyright 2010 Artur Duque de Souza <asouza@kde.org>                  *
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
#include "activityconfiguration.h"

//Qt
#include <QtDeclarative/qdeclarative.h>
#include <QtDeclarative/QDeclarativeEngine>
#include <QtDeclarative/QDeclarativeContext>
#include <QtDeclarative/QDeclarativeItem>

//KDE
#include <KDebug>
#include <KStandardDirs>

//Plasma
#include <Plasma/Containment>

ActivityConfiguration::ActivityConfiguration(QGraphicsWidget *parent)
    : Plasma::DeclarativeWidget(parent),
      m_containment(0),
      m_mainWidget(0)
{
    setQmlPath(KStandardDirs::locate("data", "plasma-mobile/activityconfiguration/view.qml"));

    if (engine()) {
        QDeclarativeContext *ctxt = engine()->rootContext();
        m_mainWidget = qobject_cast<QDeclarativeItem *>(rootObject());

        if (m_mainWidget) {
            connect(m_mainWidget, SIGNAL(closeRequested()),
                    this, SLOT(deleteLater()));
        }
    }
}

ActivityConfiguration::~ActivityConfiguration()
{
}

void ActivityConfiguration::setContainment(Plasma::Containment *cont)
{
    m_containment = cont;
}

Plasma::Containment *ActivityConfiguration::containment() const
{
    return m_containment;
}


#include "activityconfiguration.moc"
