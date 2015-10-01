/***************************************************************************
 *   Copyright 2015 Marco Martin <mart@kde.org>                            *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU Library General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU Library General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU Library General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA .        *
 ***************************************************************************/

#include "fullscreenpanel.h"

#include <QStandardPaths>

#include <QDebug>
#include <QGuiApplication>

#include <kwindowsystem.h>

#include <KWayland/Client/plasmashell.h>
#include <KWayland/Client/connection_thread.h>
#include <KWayland/Client/surface.h>
#include <KWayland/Client/registry.h>

FullScreenPanel::FullScreenPanel(QQuickWindow *parent)
    : QQuickWindow(parent)
{
    setFlags(Qt::FramelessWindowHint);
}

FullScreenPanel::~FullScreenPanel()
{
}

void FullScreenPanel::showEvent(QShowEvent *event)
{
    setVisibility(QWindow::FullScreen);
    QQuickWindow::showEvent(event);
    KWindowSystem::setState(winId(), NET::SkipTaskbar);
}


#include "fullscreenpanel.moc"

