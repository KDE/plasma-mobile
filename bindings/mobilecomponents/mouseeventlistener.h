/*
    Copyright 2011 Marco Martin <notmart@gmail.com>

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Library General Public
    License as published by the Free Software Foundation; either
    version 2 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Library General Public License for more details.

    You should have received a copy of the GNU Library General Public License
    along with this library; see the file COPYING.LIB.  If not, write to
    the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
    Boston, MA 02110-1301, USA.
*/

#ifndef MOUSEEVENTLISTENER_H
#define MOUSEEVENTLISTENER_H

#include <QDeclarativeItem>

class QDeclarativeMouseEvent : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int x READ x)
    Q_PROPERTY(int y READ y)
    Q_PROPERTY(int screenX READ screenX)
    Q_PROPERTY(int screenY READ screenY)
    Q_PROPERTY(int button READ button)
    Q_PROPERTY(int buttons READ buttons)
    Q_PROPERTY(int modifiers READ modifiers)

public:
    QDeclarativeMouseEvent(int x, int y, int screenX, int screenY,
                           Qt::MouseButton button,
                           Qt::MouseButtons buttons,
                           Qt::KeyboardModifiers modifiers)
        : m_x(x),
          m_y(y),
          m_screenX(screenX),
          m_screenY(screenY),
          m_button(button),
          m_buttons(buttons),
          m_modifiers(modifiers)
    {}

    int x() const { return m_x; }
    int y() const { return m_y; }
    int screenX() const { return m_screenX; }
    int screenY() const { return m_screenY; }
    int button() const { return m_button; }
    int buttons() const { return m_buttons; }
    int modifiers() const { return m_modifiers; }

    // only for internal usage
    void setX(int x) { m_x = x; }
    void setY(int y) { m_y = y; }

private:
    int m_x;
    int m_y;
    int m_screenX;
    int m_screenY;
    Qt::MouseButton m_button;
    Qt::MouseButtons m_buttons;
    Qt::KeyboardModifiers m_modifiers;
};

class MouseEventListener : public QDeclarativeItem
{
    Q_OBJECT

public:
    MouseEventListener(QDeclarativeItem *parent=0);
    ~MouseEventListener();

protected:
    void mousePressEvent(QGraphicsSceneMouseEvent *event);
    void mouseMoveEvent(QGraphicsSceneMouseEvent *event);
    void mouseReleaseEvent(QGraphicsSceneMouseEvent *event);
    bool sceneEventFilter(QGraphicsItem *i, QEvent *e);

Q_SIGNALS:
    void pressed(QDeclarativeMouseEvent *mouse);
    void positionChanged(QDeclarativeMouseEvent *mouse);
    void released(QDeclarativeMouseEvent *mouse);
};

#endif
