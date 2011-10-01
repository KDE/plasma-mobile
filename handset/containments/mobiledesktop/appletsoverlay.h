/*
 *   Copyright 2010 Marco Martin <mart@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Lesser General Public License as
 *   published by the Free Software Foundation; either version 2, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU Lesser General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#ifndef APPLETSOVERLAY_H
#define APPLETSOVERLAY_H

#include <QGraphicsWidget>

#include <plasma/plasma.h>

class QGraphicsAnchorLayout;

namespace Plasma
{
    class Applet;
    class IconWidget;
    class PushButton;
}

class AppletsOverlay : public QGraphicsWidget
{
    Q_OBJECT

public:
    AppletsOverlay(QGraphicsItem *parent = 0);
    ~AppletsOverlay();

    void setApplet(Plasma::Applet *applet);
    Plasma::Applet *applet();

protected:
    void paint(QPainter *painter,
               const QStyleOptionGraphicsItem *option,
               QWidget *widget);
    void mousePressEvent(QGraphicsSceneMouseEvent *event);
    void mouseReleaseEvent(QGraphicsSceneMouseEvent *event);
    void resizeEvent(QGraphicsSceneResizeEvent *event);

protected Q_SLOTS:
    void configureApplet();
    void toggleDeleteButton();
    void closeApplet();

Q_SIGNALS:
    void closeRequested();
    void configureRequested();

private:
    QWeakPointer<Plasma::Applet> m_applet;
    QWeakPointer<Plasma::PushButton> m_closeButton;
    QGraphicsAnchorLayout *m_layout;
    Plasma::IconWidget *m_askCloseButton;
};

#endif
