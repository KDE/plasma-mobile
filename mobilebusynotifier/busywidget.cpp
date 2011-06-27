/*
 *   Copyright 2011 Marco Martin <notmart@gmail.com>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License version 2 as
 *   published by the Free Software Foundation
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#include "busywidget.h"

#include <QApplication>
#include <QDesktopWidget>

#include <Plasma/Svg>

BusyWidget::BusyWidget(QWidget *parent)
    : QWidget(parent)
{
    QDesktopWidget *desktop = QApplication::desktop();
    connect(desktop, SIGNAL(resized(int )), this, SLOT(updateGeometry()));
    QRect screenGeom = desktop->screenGeometry(desktop->screenNumber(this));
    setFixedSize(screenGeom.size());

    hide();
    updateGeometry();
}

BusyWidget::~BusyWidget()
{
}


#include "busywidget.moc"

