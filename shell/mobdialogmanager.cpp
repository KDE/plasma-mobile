/*
 *   Copyright (C) 2010 Marco Martin <notmart@gmail.com>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License as
 *   published by the Free Software Foundation; either version 2, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#include "mobdialogmanager.h"

#include <QtGui/QWidget>
#include <QtGui/QStyleOptionGraphicsItem>
#include <QtGui/QGraphicsProxyWidget>
#include <QtGui/QPainter>
#include <QtGui/QApplication>

#include <KWindowSystem>

#include <Plasma/Applet>
#include <Plasma/Containment>
#include <Plasma/Corona>
#include <Plasma/WindowEffects>

MobDialogManager::MobDialogManager(Plasma::Corona *parent)
    : Plasma::AbstractDialogManager(parent),
      m_corona(parent)
{
}

MobDialogManager::~MobDialogManager()
{
}

void MobDialogManager::showDialog(QWidget *widget, Plasma::Applet *applet)
{
    Q_UNUSED(applet)
    if (KWindowSystem::compositingActive()) {
        widget->setAttribute(Qt::WA_WindowPropagation, false);
        widget->setAttribute(Qt::WA_TranslucentBackground);
        widget->setAttribute(Qt::WA_NoSystemBackground, false);
        widget->setWindowFlags(Qt::FramelessWindowHint);
        KWindowSystem::setState(widget->effectiveWinId(), NET::MaxVert|NET::MaxHoriz);
        Plasma::WindowEffects::enableBlurBehind(widget->effectiveWinId(), true);

        QPalette palette = widget->palette();
        palette.setColor(QPalette::Window, QColor(0,0,0,100));
        widget->setAttribute(Qt::WA_WindowPropagation);
        palette.setColor(QPalette::WindowText, Qt::white);
        palette.setColor(QPalette::ToolTipText, Qt::white);
        widget->setPalette(palette);
    }

    Plasma::Containment *containment = applet->containment();
    if (containment) {
        Plasma::Corona *corona = containment->corona();
        if (corona) {
            QRect r = corona->availableScreenRegion(containment->screen()).boundingRect();
            //assumption: the panel is 100% wide
            QRect screenRect = corona->screenGeometry(containment->screen());

            widget->setContentsMargins(r.left() - screenRect.left(),
                                       r.top() - screenRect.top(),
                                       screenRect.right() - r.right(),
                                       screenRect.bottom() - r.bottom());
        }
    }

    widget->show();
}


#include "mobdialogmanager.moc"
