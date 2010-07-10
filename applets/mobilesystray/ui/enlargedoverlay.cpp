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

EnlargedOverlay::EnlargedOverlay(QList<Task*> tasks, QSize containerSize, Plasma::Applet *par)
        : Applet(par)
{
    parent = par;
    m_layout = new QGraphicsLinearLayout(Qt::Horizontal, this);
    Plasma::IconWidget *cancel = new Plasma::IconWidget(KIcon("dialog-cancel"), "", this);
    connect(cancel, SIGNAL(clicked()), this, SLOT(hideOverlay()));
    m_layout->addItem(cancel);
    foreach(Task *task, tasks) {
        if (task->isEmbeddable(parent)) {
            QGraphicsWidget *w = task->widget(parent, true);
            if (!w) {
              continue;
            }
            m_layout->addItem(w);
            m_widgetList.insert(task->typeId(), w);
            w->setParent(this);
            //Plasma::IconWidget *w = qobject_cast<Plasma::IconWidget*>(task->widget(this, true));
            //layout->addItem(w);
            //w->setIcon(task->icon());
            //Plasma::IconWidget *w = new Plasma::IconWidget(task->icon(), "", this);
            //layout->addItem(w);
            DBusSystemTrayWidget *d = qobject_cast<DBusSystemTrayWidget*>(w);
            if (d != 0) {
                d->setIcon("", task->icon());
                d->setItemIsMenu(false);
                /*QAction *q = new QAction(task->icon(), "", this);
                connect(q, SIGNAL(triggered()), d, SLOT(emitMenu()));
                w->setAction(q);
                //connect(d, SIGNAL(clicked()), d, SLOT(emitMenu()));
                connect(d, SIGNAL(menuEmitted(QMenu*)), this, SLOT(relayMenu(QMenu*)));*/
            }
        }
    }

    m_background.setImagePath("widgets/translucentbackground");
    m_background.setEnabledBorders(FrameSvg::AllBorders);

    resize(containerSize.width() - 100, 100);
    setZValue(9999);
}

EnlargedOverlay::~EnlargedOverlay()
{
}

void EnlargedOverlay::addTask(SystemTray::Task* task)
{
    QGraphicsWidget *w = task->widget(parent, true);
    if (!w) return;
    m_layout->addItem(w);
    m_widgetList.insert(task->typeId(), w);
    DBusSystemTrayWidget *d = qobject_cast<DBusSystemTrayWidget*>(w);
    if (d != 0) {
        d->setIcon("", task->icon());
        d->setItemIsMenu(false);
    }
}

void EnlargedOverlay::removeTask(SystemTray::Task* task)
{
    QGraphicsWidget *ic = m_widgetList.take(task->typeId());
    if (ic) {
        m_layout->removeItem(ic);
        delete ic;
    }
}

void EnlargedOverlay::updateTask(SystemTray::Task* task)
{
    removeTask(task);
    addTask(task);
}

void EnlargedOverlay::hideOverlay()
{
    hide();
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