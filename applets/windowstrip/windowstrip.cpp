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

#include "windowstrip.h"

#include <QtGui/QGraphicsLinearLayout>

#include <Plasma/Svg>
#include <Plasma/WindowEffects>

#include <KStandardDirs>
#include <KWindowSystem>

WindowStrip::WindowStrip(QObject *parent, const QVariantList &args)
    : Plasma::Applet(parent, args),
    m_widget(0)
{
    kDebug() << "ctor......";
}

WindowStrip::~WindowStrip()
{
    hideThumbnails();
    kDebug() << "dtor......";
}

void WindowStrip::init()
{
    kDebug() << "init......";
    graphicsWidget();
    QList< WId > windows = KWindowSystem::windows();

    int x, y, w, h, s;
    x = 50;
    y = 50;
    w = 200;
    h = 200;
    s = 20;
    foreach (const WId wid, windows) {
        m_windows[wid] = QRect(x, y, w, h);
        x = x + w + s;
        kDebug() << "Window ID:" << w << m_windows[wid];
    }

    QTimer::singleShot(5000, this, SLOT(hideThumbnails()));
    showThumbnails();
}

QGraphicsWidget* WindowStrip::graphicsWidget()
{
    kDebug() << "gw......";
    if (!m_widget) {
        QGraphicsLinearLayout *l = new QGraphicsLinearLayout(this);
        m_widget = new Plasma::DeclarativeWidget(this);
        kDebug() << "PATH: " << KStandardDirs::locate("data", "plasma/plasmoids/org.kde.windowstrip/WindowStrip.qml");
        l->addItem(m_widget);

        m_widget->setQmlPath(KStandardDirs::locate("data", "plasma/plasmoids/org.kde.windowstrip/WindowStrip.qml"));
    }
    return m_widget;
}

void WindowStrip::showThumbnails()
{
    Plasma::WindowEffects::showWindowThumbnails(35651702, m_windows.keys(), m_windows.values());
    kDebug() << "/// all shown" << m_windows.keys() << m_windows.values();
}

void WindowStrip::hideThumbnails()
{
    QList<WId> w;
    QList<QRect> r;
    //Plasma::WindowEffects::showWindowThumbnails(35651702, w, r);
    Plasma::WindowEffects::showWindowThumbnails(35651702);
    kDebug() << "/// all hidden ";
}

K_EXPORT_PLASMA_APPLET(windowstrip, WindowStrip)

#include "windowstrip.moc"