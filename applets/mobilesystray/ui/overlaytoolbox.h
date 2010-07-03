/*
 *   Copyright 2008 Marco Martin <notmart@gmail.com>
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

#ifndef OVERLAYTOOLBOX_H
#define OVERLAYTOOLBOX_H

#include <QAction>
#include <QMenu>
#include <QGraphicsWidget>
#include <QGraphicsSceneResizeEvent>
#include <QGraphicsSceneMouseEvent>

#include <Plasma/Label>
#include <Plasma/FrameSvg>


class OverlayToolBox : public QGraphicsWidget
{
    Q_OBJECT

public:
    OverlayToolBox(const QString &title, QGraphicsWidget *parent = 0);
    ~OverlayToolBox();

    void addTool(QAction *action);

public slots:
    void setMainMenu(QMenu* m);

protected:
    void paint(QPainter *painter, const QStyleOptionGraphicsItem *option,
               QWidget *widget = 0);

    void resizeEvent(QGraphicsSceneResizeEvent *event);

private:
    int m_totalActions;
    Plasma::FrameSvg m_background;
};


#endif
