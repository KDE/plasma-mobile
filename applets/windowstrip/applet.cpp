/***************************************************************************
 *                                                                         *
 *   Copyright 2011 Sebastian Kügler <sebas@kde.org>                       *
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

#include "applet.h"
#include "windowstrip.h"

#include <QtGui/QGraphicsLinearLayout>

#include <Plasma/Svg>
#include <Plasma/WindowEffects>

#include <KStandardDirs>
#include <KWindowSystem>

WindowStripApplet::WindowStripApplet(QObject *parent, const QVariantList &args)
    : Plasma::Containment(parent, args),
    m_widget(0)
{
    kDebug() << "ctor......";
    setContainmentType(Containment::CustomContainment);
    setHasConfigurationInterface(false);
}

WindowStripApplet::~WindowStripApplet()
{
    kDebug() << "dtor......";
}

void WindowStripApplet::init()
{
    Plasma::Containment::init();
    graphicsWidget();
}

QGraphicsWidget* WindowStripApplet::graphicsWidget()
{
    kDebug() << "gw......";
    if (!m_widget) {
        setContentsMargins(0, 0, 0, 0);
        QGraphicsLinearLayout *l = new QGraphicsLinearLayout(this);
        l->setContentsMargins(0, 0, 0, 0);
        m_widget = new WindowStrip(this);
        l->addItem(m_widget);
    }
    return m_widget;
}

K_EXPORT_PLASMA_APPLET(windowstrip, WindowStripApplet)

#include "applet.moc"