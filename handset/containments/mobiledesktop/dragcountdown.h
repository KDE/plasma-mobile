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

#ifndef DRAGCOUNT_H
#define DRAGCOUNT_H

#include <QGraphicsWidget>

class QTimer;

namespace Plasma
{
    class Svg;
}

class DragCountdown : public QGraphicsWidget
{
    Q_OBJECT

public:
    DragCountdown(QGraphicsItem *parent=0);
    ~DragCountdown();

    void start(const int timeout);
    void stop();

protected:
    void paint(QPainter *painter, const QStyleOptionGraphicsItem *option, QWidget *widget = 0);

protected Q_SLOTS:
    void updateProgress();

Q_SIGNALS:
    void dragRequested();

private:
    qreal m_progress;
    qreal m_increment;
    QTimer *m_animationTimer;
    QTimer *m_countdownTimer;
    Plasma::Svg *m_icons;
};

#endif
