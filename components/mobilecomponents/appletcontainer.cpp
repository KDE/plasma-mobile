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

#include "appletcontainer.h"

#include <QGraphicsLayout>

#include <KDebug>

#include <Plasma/Applet>

AppletContainer::AppletContainer(QDeclarativeItem *parent)
    : QDeclarativeItem(parent)
{
    setFlag(QGraphicsItem::ItemHasNoContents, true);

    //the virtual geometryChanged is *NOT* called in case of change by the anchors
    connect(this, SIGNAL(widthChanged()), this, SLOT(afterWidthChanged()), Qt::QueuedConnection);
    connect(this, SIGNAL(heightChanged()), this, SLOT(afterHeightChanged()), Qt::QueuedConnection);
}

AppletContainer::~AppletContainer()
{
}

QGraphicsWidget *AppletContainer::applet() const
{
    return m_applet.data();
}

void AppletContainer::setApplet(QGraphicsWidget *widget)
{
    Plasma::Applet *applet = qobject_cast<Plasma::Applet *>(widget);
    if (!applet || applet == m_applet.data()) {
        return;
    }

    if (m_applet) {
        disconnect(m_applet.data(), 0, this, 0);
        m_applet.data()->setParentItem(parentItem());
    }

    m_applet = applet;

    connect(applet, SIGNAL(sizeHintChanged(Qt::SizeHint)), this, SLOT(sizeHintChanged(Qt::SizeHint)));
    connect(applet, SIGNAL(newStatus(Plasma::ItemStatus)), this, SIGNAL(statusChanged()));

    applet->setParentItem(this);
    applet->setGeometry(0, 0, qMax((qreal)16, width()), qMax((qreal)16, height()));
    applet->setFlag(QGraphicsItem::ItemIsMovable, false);

    emit appletChanged(widget);
    emit statusChanged();
}

void AppletContainer::sizeHintChanged(Qt::SizeHint which)
{
    switch (which) {
    case Qt::MinimumSize:
        emit minimumWidthChanged(minimumWidth());
        emit minimumHeightChanged(minimumHeight());
        break;
    case Qt::PreferredSize:
        emit preferredWidthChanged(preferredWidth());
        emit preferredHeightChanged(preferredHeight());
        break;
    case Qt::MaximumSize:
        emit maximumWidthChanged(maximumWidth());
        emit maximumHeightChanged(maximumHeight());
        break;
    default:
        break;
    }
}

int AppletContainer::minimumWidth() const
{
    if (!m_applet) {
        return -1;
    }

    return m_applet.data()->effectiveSizeHint(Qt::MinimumSize).width();
}

int AppletContainer::minimumHeight() const
{
    if (!m_applet) {
        return -1;
    }

    return m_applet.data()->effectiveSizeHint(Qt::MinimumSize).height();
}


int AppletContainer::preferredWidth() const
{
    if (!m_applet) {
        return -1;
    }

    return m_applet.data()->effectiveSizeHint(Qt::PreferredSize).width();
}

int AppletContainer::preferredHeight() const
{
    if (!m_applet) {
        return -1;
    }

    return m_applet.data()->effectiveSizeHint(Qt::PreferredSize).height();
}


int AppletContainer::maximumWidth() const
{
    if (!m_applet) {
        return -1;
    }

    return m_applet.data()->effectiveSizeHint(Qt::MaximumSize).width();
}

int AppletContainer::maximumHeight() const
{
    if (!m_applet) {
        return -1;
    }

    return m_applet.data()->effectiveSizeHint(Qt::MaximumSize).height();
}

void AppletContainer::setStatus(const AppletContainer::ItemStatus status)
{
    if (!m_applet) {
        return;
    }

    m_applet.data()->setStatus((Plasma::ItemStatus)status);
}

AppletContainer::ItemStatus AppletContainer::status() const
{
    if (!m_applet) {
        return UnknownStatus;
    }

    return (AppletContainer::ItemStatus)((int)(m_applet.data()->status()));
}

void AppletContainer::afterWidthChanged()
{
    if (!m_applet) {
        return;
    }

    m_applet.data()->resize(width(), height());
    m_applet.data()->setPos(width()/2 - m_applet.data()->size().width()/2,
                            height()/2 - m_applet.data()->size().height()/2);
    emit minimumWidthChanged(minimumWidth());
    emit preferredWidthChanged(preferredWidth());
    emit maximumWidthChanged(maximumWidth());

    emit minimumHeightChanged(minimumHeight());
    emit preferredHeightChanged(preferredHeight());
    emit maximumHeightChanged(maximumHeight());
}

void AppletContainer::afterHeightChanged()
{
    if (!m_applet) {
        return;
    }

    m_applet.data()->resize(width(), height());
    m_applet.data()->setPos(width()/2 - m_applet.data()->size().width()/2,
                            height()/2 - m_applet.data()->size().height()/2);

    emit minimumWidthChanged(minimumWidth());
    emit preferredWidthChanged(preferredWidth());
    emit maximumWidthChanged(maximumWidth());

    emit minimumHeightChanged(minimumHeight());
    emit preferredHeightChanged(preferredHeight());
    emit maximumHeightChanged(maximumHeight());
}


#include "appletcontainer.moc"
