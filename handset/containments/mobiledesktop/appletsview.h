/*
 *   Copyright 2010 Marco Martin <mart@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2, or
 *   (at your option) any later version.
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

#ifndef APPLETSVIEW_H
#define APPLETSVIEW_H

#include <Plasma/ScrollWidget>

#include "appletscontainer.h"

class QTimer;

namespace Plasma
{
    class Applet;
}

class DragCountdown;

class AppletsView : public Plasma::ScrollWidget
{
    Q_OBJECT
    friend class AppletsContainer;

public:
    AppletsView(QGraphicsItem *parent = 0);
    ~AppletsView();

    void setAppletsContainer(AppletsContainer *appletsContainer);
    AppletsContainer *appletsContainer() const;

    void setOrientation(const Qt::Orientation orientation);
    Qt::Orientation orientation() const;

protected Q_SLOTS:
    void appletDragRequested();
    void scrollTimeout();

protected:
    bool sceneEventFilter(QGraphicsItem *watched, QEvent *event);
    void paint(QPainter *painter,
               const QStyleOptionGraphicsItem *option,
               QWidget *widget);

private:
    AppletsContainer *m_appletsContainer;
    DragCountdown *m_dragCountdown;
    bool m_movingApplets;
    bool m_scrollDown;
    QTimer *m_scrollTimer;
    QWeakPointer<Plasma::Applet> m_draggingApplet;
};

#endif
