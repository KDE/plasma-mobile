/*
 *   Copyright (C) 2010 Marco Martin <notmart@gmail.com>
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

#include "mobdialogmanager.h"

#include <QtGui/QWidget>
#include <QtGui/QStyleOptionGraphicsItem>
#include <QtGui/QGraphicsProxyWidget>
#include <QtGui/QPainter>
#include <QtGui/QApplication>

#include <Plasma/Applet>
#include <Plasma/Animation>
#include <Plasma/Animator>
#include <Plasma/Corona>
#include <Plasma/ScrollWidget>

class ProxyScroller : public Plasma::ScrollWidget
{
public:
    ProxyScroller(QGraphicsItem *parent=0)
       : Plasma::ScrollWidget(parent)
    {
        setFlag(QGraphicsItem::ItemHasNoContents, false);
        setHorizontalScrollBarPolicy(Qt::ScrollBarAlwaysOff);
        setVerticalScrollBarPolicy(Qt::ScrollBarAlwaysOff);
    }

    void paint(QPainter *painter, const QStyleOptionGraphicsItem *option, QWidget * widget=0)
    {
        Q_UNUSED(widget)
        painter->fillRect(option->rect, QColor(0, 0, 0, 185));
    }
};

class WidgetProxy : public QGraphicsProxyWidget
{
public:
    WidgetProxy(QWidget *widget, QGraphicsItem *parent=0)
      : QGraphicsProxyWidget(parent)
    {
        widget->setAttribute(Qt::WA_WindowPropagation, false);
        widget->setAttribute(Qt::WA_TranslucentBackground);

        QPalette palette = widget->palette();
        palette.setColor(QPalette::Window, QColor(255,255,255,100));
        widget->setAttribute(Qt::WA_WindowPropagation);
        palette.setColor(QPalette::WindowText, Qt::white);
        palette.setColor(QPalette::ToolTipText, Qt::white);
        widget->setPalette(palette);

        setWidget(widget);
    }

};



MobDialogManager::MobDialogManager(Plasma::Corona *parent)
    : Plasma::AbstractDialogManager(parent),
      m_corona(parent)
{
}

MobDialogManager::~MobDialogManager()
{
}

void MobDialogManager::showDialog(QWidget *widget, Plasma::Applet *applet)
{
    ProxyScroller *scroll = m_managedDialogs.value(widget);
    if (!scroll) {
        scroll = new ProxyScroller;
        WidgetProxy *proxy = new WidgetProxy(widget, scroll);
        scroll->setWidget(proxy);
        m_managedDialogs.insert(widget, scroll);
        connect(widget, SIGNAL(destroyed(QObject *)), this, SLOT(dialogDestroyed(QObject *)));

        m_corona->addItem(scroll);
        if (applet && applet->containment()) {
            scroll->setGeometry(scroll->mapFromScene(applet->containment()->mapToScene(applet->containment()->boundingRect())).boundingRect());
            proxy->setGeometry(QRectF(QPointF(4, 4), applet->containment()->size()-QSizeF(18,18)));
        }
    }
    Plasma::Animation *fade = Plasma::Animator::create(Plasma::Animator::FadeAnimation, this);
    fade->setTargetWidget(scroll);
    fade->setProperty("startOpacity", 0.0);
    fade->setProperty("targetOpacity", 1.0);
    scroll->setOpacity(0);
    scroll->show();
    fade->start(QAbstractAnimation::DeleteWhenStopped);
}

void MobDialogManager::dialogDestroyed(QObject *object)
{
    QWidget *widget = static_cast<QWidget *>(object);
    Plasma::ScrollWidget *scroll = m_managedDialogs.value(widget);

    if (scroll) {
        scroll->deleteLater();
    }

    m_managedDialogs.remove(widget);
}

#include "mobdialogmanager.moc"
