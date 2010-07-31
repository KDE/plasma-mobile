/*
 *   Copyright 2009 Marco Martin <notmart@gmail.com>
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

#ifndef PLASMA_RESULTWIDGET_H
#define PLASMA_RESULTWIDGET_H

#include <QTimer>

#include <Plasma/IconWidget>

class QPropertyAnimation;

class ResultWidget : public Plasma::IconWidget
{
    Q_OBJECT
    Q_PROPERTY(QPointF animationPos READ animationPos WRITE setAnimationPos)
    Q_PROPERTY(QSizeF preferredIconSize READ preferredIconSize WRITE setPreferredIconSize)
    Q_PROPERTY(QSizeF minimumIconSize READ minimumIconSize WRITE setMinimumIconSize)
    Q_PROPERTY(QSizeF maximumIconSize READ maximumIconSize WRITE setMaximumIconSize)

public:
    ResultWidget(QGraphicsItem *parent = 0);
    ~ResultWidget();

    void setGeometry(const QRectF &rect);

    QPointF animationPos() const;
    void setAnimationPos(const QPointF &pos);

protected:
    void mousePressEvent(QGraphicsSceneMouseEvent *event);
    void mouseMoveEvent(QGraphicsSceneMouseEvent *event);
    void mouseReleaseEvent(QGraphicsSceneMouseEvent *event);

    void hideEvent(QHideEvent *event);
    void showEvent(QShowEvent *event);

protected Q_SLOTS:
    void hideTimeout();

Q_SIGNALS:
    void dragStartRequested(Plasma::IconWidget *);

private:
    QPropertyAnimation *m_animation;
    QTimer *m_hideTimer;
    bool m_animationLock;
    bool m_hiding;
};

#endif
