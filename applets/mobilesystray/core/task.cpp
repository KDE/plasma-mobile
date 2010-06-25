/***************************************************************************
 *   task.cpp                                                              *
 *                                                                         *
 *   Copyright (C) 2008 Jason Stubbs <jasonbstubbs@gmail.com>              *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA .        *
 ***************************************************************************/

#include "task.h"

#include <QtGui/QGraphicsWidget>


namespace SystemTray
{


class Task::Private
{
public:
    Private()
        : hiddenState(Task::NotHidden),
          order(Task::Normal),
          status(Task::UnknownStatus),
          category(Task::UnknownCategory)
    {
    }

    QHash<Plasma::Applet *, QGraphicsWidget *> widgetsByHost;
    Task::HideStates hiddenState;
    Task::Order order;
    Task::Status status;
    Task::Category category;
};


Task::Task(QObject *parent)
    : QObject(parent),
      d(new Private)
{
}

Task::~Task()
{
    emit destroyed(this);
    foreach (QGraphicsWidget * widget, d->widgetsByHost) {
        disconnect(widget, 0, this, 0);
        delete widget;
    }
    delete d;
}


QGraphicsWidget* Task::widget(Plasma::Applet *host, bool createIfNecessary)
{
    Q_ASSERT(host);

    QGraphicsWidget *widget = d->widgetsByHost.value(host);

    if (!widget && createIfNecessary) {
        widget = createWidget(host);

        if (widget) {
            d->widgetsByHost.insert(host, widget);
            connect(widget, SIGNAL(destroyed()), this, SLOT(widgetDeleted()));
        }
    }

    return widget;
}

bool Task::isEmbeddable(Plasma::Applet *host)
{
    if (!host) {
        return false;
    }

    return d->widgetsByHost.value(host) || isEmbeddable();
}

QHash<Plasma::Applet *, QGraphicsWidget *> Task::widgetsByHost() const
{
    return d->widgetsByHost;
}

void Task::widgetDeleted()
{
    bool wasEmbeddable = isEmbeddable();

    QGraphicsWidget * w = static_cast<QGraphicsWidget*>(sender());
    QMutableHashIterator<Plasma::Applet *, QGraphicsWidget *> it(d->widgetsByHost);
    while (it.hasNext()) {
        it.next();
        if (it.value() == w) {
            it.remove();
        }
    }

    if (!wasEmbeddable && isEmbeddable()) {
        emit changed(this);
    }
}

bool Task::isHideable() const
{
    return true;
}

void Task::setHidden(HideStates state)
{
    d->hiddenState = state;
}

Task::HideStates Task::hidden() const
{
    return d->hiddenState;
}

bool Task::isUsed() const
{
    return !d->widgetsByHost.isEmpty();
}

Task::Order Task::order() const
{
    return d->order;
}

void Task::setOrder(Order order)
{
    d->order = order;
}

void Task::setCategory(Category category)
{
    if (d->category == category) {
        return;
    }

    d->category = category;
    emit changed(this);
}

Task::Category Task::category() const
{
    return d->category;
}

void Task::setStatus(Status status)
{
    if (d->status == status) {
        return;
    }

    d->status = status;
    resetHiddenStatus();
    emit changed(this);
}

Task::Status Task::status() const
{
    return d->status;
}

void Task::resetHiddenStatus()
{
    if (d->status == NeedsAttention) {
        setOrder(First);
        if (hidden() & AutoHidden) {
            setHidden(hidden() ^ AutoHidden);
        }
    } else {
        if (d->status == Active && (hidden() & AutoHidden)) {
            setHidden(hidden() ^ AutoHidden);
        } else if (d->status == Passive) {
            setHidden(hidden() | AutoHidden);
        }

        setOrder(Normal);
    }
}

}


#include "task.moc"
