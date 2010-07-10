/*
 *   Copyright 2008 Lim Yuen Hoe <yuenhoe@hotmail.com>
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

#ifndef ENLARGEDOVERLAY_H
#define ENLARGEDOVERLAY_H

#include <KAction>
#include <QGraphicsWidget>
#include <QGraphicsSceneResizeEvent>
#include <QGraphicsSceneMouseEvent>
#include <QHash>

#include <Plasma/Label>
#include <Plasma/FrameSvg>
#include <Plasma/Applet>

#include "../core/task.h"

namespace Plasma
{
  class Applet;
}

class QGraphicsLinearLayout;

namespace SystemTray
{

class EnlargedOverlay : public Plasma::Applet
{
    Q_OBJECT

public:
    EnlargedOverlay(QList<Task*> tasks, QSize containerSize, Plasma::Applet *par = 0);
    ~EnlargedOverlay();

public slots:
    void addTask(SystemTray::Task* task);
    void removeTask(SystemTray::Task* task);
    void updateTask(SystemTray::Task* task);

signals:
    void showMenu(QMenu* m);

protected slots:
    void relayMenu(QMenu* m);
    void hideOverlay();

protected:
    void paint(QPainter *painter, const QStyleOptionGraphicsItem *option,
               QWidget *widget = 0);
    void resizeEvent(QGraphicsSceneResizeEvent *event);

private:
    QHash<QString, QGraphicsWidget*> m_widgetList;
    QGraphicsLinearLayout *m_layout;
    Plasma::Applet* parent;
    Plasma::FrameSvg m_background;
};

}

#endif
