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

FullScreenPanel::FullScreenPanel(QQuickWindow *parent)
    : QQuickWindow(parent)
{
    setFlags(Qt::FramelessWindowHint);
    setWindowState(Qt::WindowFullScreen);
   // connect(this, &FullScreenPanel::activeFocusItemChanged, this, [this]() {qWarning()<<"hide()";});
    connect(this, &QWindow::activeChanged, this, &FullScreenPanel::activeChanged);
}

FullScreenPanel::~FullScreenPanel()
{
}

void FullScreenPanel::showEvent(QShowEvent *event)
{
    QQuickWindow::showEvent(event);
    KWindowSystem::setState(winId(), NET::SkipTaskbar);
}


#include "fullscreenpanel.moc"

