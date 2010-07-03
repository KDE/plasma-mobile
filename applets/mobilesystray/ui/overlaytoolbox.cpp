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

#include "overlaytoolbox.h"


#include <QPainter>

#include <Plasma/IconWidget>
#include <KDebug>

using namespace Plasma;

OverlayToolBox::OverlayToolBox(const QString &title, QGraphicsWidget *parent)
        : QGraphicsWidget(parent), m_totalActions(0)
{
    setAcceptsHoverEvents(true);

    m_background.setImagePath("widgets/translucentbackground");
    m_background.setEnabledBorders(FrameSvg::AllBorders);
    
    Plasma::IconWidget *tool = new Plasma::IconWidget(title, this);

    // Add menu title
    tool->setAction(0L);
    tool->setOrientation(Qt::Horizontal);
    tool->resize(tool->sizeFromIconSize(22));

    tool->setPos(QPoint(30, 10));
    tool->resize(size().width() - 60, tool->size().height() + 50);
    tool->setZValue(zValue() + 10);
}

OverlayToolBox::~OverlayToolBox()
{
}

void OverlayToolBox::resizeEvent(QGraphicsSceneResizeEvent *event)
{
    m_background.resizeFrame(event->newSize());

    foreach(QGraphicsItem *child, QGraphicsItem::children()) {
        Plasma::IconWidget *tool = dynamic_cast<Plasma::IconWidget*>(child);
        tool->resize(size().width() - 60, tool->size().height());
    }

}

void OverlayToolBox::paint(QPainter *painter, const QStyleOptionGraphicsItem *option,
                           QWidget *widget)
{
    Q_UNUSED(option);
    Q_UNUSED(widget);

    m_background.paintFrame(painter);
}

void OverlayToolBox::setMainMenu(QMenu* m)
{
    QList<QAction*> actions = m->actions();
    for (int i=0; i<actions.size(); i++) {
        QAction* action = actions.at(i);
        if (!action->isSeparator() && !action->menu()) {
            addTool(action);
        }
    }
}

void OverlayToolBox::addTool(QAction *action)
{
    if (!action) {
        return;
    }

    Plasma::IconWidget *tool = new Plasma::IconWidget(this);

    tool->setAction(action);
    tool->setDrawBackground(true);
    tool->setOrientation(Qt::Horizontal);
    tool->resize(tool->sizeFromIconSize(22));

    const int height = 70; //static_cast<int>(tool->boundingRect().height());
    tool->setPos(QPoint(30, 10 + (m_totalActions * height)));
    tool->resize(size().width() - 60, height);//tool->size().height());
    tool->setZValue(zValue() + 10);
    tool->setToolTip(action->text());

    //make enabled/disabled tools appear/disappear instantly
    //    connect(tool, SIGNAL(changed()), this, SLOT(updateToolBox()));
    //connect(action, SIGNAL(triggered(bool)), this, SLOT(toolTriggered(bool)));

    m_totalActions++;
}

