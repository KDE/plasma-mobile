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

#include "enlargedoverlay.h"
#include "../protocols/dbussystemtray/dbussystemtraywidget.h"

#include <QPainter>
#include <QGraphicsLinearLayout>
#include <QDesktopWidget>

#include <Plasma/IconWidget>
#include <KDebug>
#include <KIcon>

using namespace Plasma;

namespace SystemTray
{

EnlargedOverlay::EnlargedOverlay(QList<Task*> tasks, QSize containerSize, QGraphicsWidget *parent)
        : Applet(parent)
{
    QGraphicsLinearLayout *layout = new QGraphicsLinearLayout(Qt::Horizontal, this);
    foreach(Task *task, tasks) {
      /*Plasma::IconWidget *w = qobject_cast<Plasma::IconWidget*>(task->widget(this, true));
      layout->addItem(w);
      w->setIcon(task->icon());*/
      Plasma::IconWidget *w = new Plasma::IconWidget(task->icon(), "", this);
      layout->addItem(w);
      DBusSystemTrayWidget *d = qobject_cast<DBusSystemTrayWidget*>(task->widget(this, true));
      if (d != 0) {
          QAction *q = new QAction(task->icon(), "", this);
          connect(q, SIGNAL(triggered()), d, SLOT(emitMenu()));
          w->setAction(q);
          //connect(d, SIGNAL(clicked()), d, SLOT(emitMenu()));
          connect(d, SIGNAL(menuEmitted(QMenu*)), this, SLOT(relayMenu(QMenu*)));
      }
    }

    m_background.setImagePath("widgets/translucentbackground");
    m_background.setEnabledBorders(FrameSvg::AllBorders);

    resize(containerSize.width() - 100, 100);
} 

EnlargedOverlay::~EnlargedOverlay()
{
}

void EnlargedOverlay::relayMenu(QMenu* m)
{
    emit showMenu(m);
}

void EnlargedOverlay::resizeEvent(QGraphicsSceneResizeEvent *event)
{
    m_background.resizeFrame(event->newSize());
}

void EnlargedOverlay::paint(QPainter *painter, const QStyleOptionGraphicsItem *option,
                           QWidget *widget)
{
    Q_UNUSED(option);
    Q_UNUSED(widget);

    m_background.paintFrame(painter);
}

}