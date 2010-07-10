/***************************************************************************
 *                                                                         *
 *   Copyright (C) 2009 Aaron Seigo <aseigo@kde.org>                       *
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

#include "dbussystemtraywidget.h"

#include <QApplication>
#include <QDBusAbstractInterface>
#include <QDesktopWidget>
#include <QGraphicsSceneWheelEvent>
#include <QMenu>

#include <KAction>

#include <Plasma/Containment>
#include <Plasma/Corona>
#include <Plasma/ServiceJob>
#include <Plasma/Theme>

namespace SystemTray
{

DBusSystemTrayWidget::DBusSystemTrayWidget(Plasma::Applet *parent, Plasma::Service *service)
    : Plasma::IconWidget(parent),
      m_service(service),
      m_host(parent),
      m_waitingOnContextMenu(false)
{
    KAction *action = new KAction(this);
    setAction(action);
    connect(action, SIGNAL(triggered()), this, SLOT(calculateShowPosition()));
}

void DBusSystemTrayWidget::mousePressEvent(QGraphicsSceneMouseEvent *event)
{
    Plasma::IconWidget::mousePressEvent(event);

    if (event->button() == Qt::MidButton) {
        event->accept();
    }
}

void DBusSystemTrayWidget::setItemIsMenu(bool itemIsMenu)
{
    m_itemIsMenu = itemIsMenu;
}

bool DBusSystemTrayWidget::itemIsMenu() const
{
    return m_itemIsMenu;
}

void DBusSystemTrayWidget::mouseReleaseEvent(QGraphicsSceneMouseEvent *event)
{
    if (event->button() == Qt::MidButton) {
        KConfigGroup params = m_service->operationDescription("SecondaryActivate");
        params.writeEntry("x", event->screenPos().x());
        params.writeEntry("y", event->screenPos().y());
        m_service->startOperationCall(params);
    } else if (m_itemIsMenu && !m_waitingOnContextMenu) {
        m_waitingOnContextMenu = true;
        KConfigGroup params = m_service->operationDescription("ContextMenu");
        params.writeEntry("x", event->screenPos().x());
        params.writeEntry("y", event->screenPos().y());
        KJob *job = m_service->startOperationCall(params);
        connect(job, SIGNAL(result(KJob*)), this, SLOT(showContextMenu(KJob*)));
        return;
    }

    Plasma::IconWidget::mouseReleaseEvent(event);
}

void DBusSystemTrayWidget::wheelEvent(QGraphicsSceneWheelEvent *event)
{
    KConfigGroup params = m_service->operationDescription("Scroll");
    params.writeEntry("delta", event->delta());
    params.writeEntry("direction", "Vertical");
    m_service->startOperationCall(params);
}

void DBusSystemTrayWidget::contextMenuEvent(QGraphicsSceneContextMenuEvent *event)
{
    if (m_waitingOnContextMenu) {
        return;
    }

    m_waitingOnContextMenu = true;
    KConfigGroup params = m_service->operationDescription("ContextMenu");
    params.writeEntry("x", event->screenPos().x());
    params.writeEntry("y", event->screenPos().y());
    KJob *job = m_service->startOperationCall(params);
    connect(job, SIGNAL(result(KJob*)), this, SLOT(showContextMenu(KJob*)));
}

void DBusSystemTrayWidget::showContextMenu(KJob *job)
{
    m_waitingOnContextMenu = false;
    Plasma::ServiceJob *sjob = qobject_cast<Plasma::ServiceJob *>(job);
    if (!sjob) {
        return;
    }

    QMenu *menu = qobject_cast<QMenu *>(sjob->result().value<QObject *>());
    if (menu) {
        if (m_host->containment() && m_host->containment()->corona()) {
            menu->adjustSize();
            QPoint p = m_host->containment()->corona()->popupPosition(this, menu->size());
            //kDebug() << "execing at: " << p << menu->size();
            menu->exec(p);
        } else {
            // Compute a reasonable position for the menu if we don't have a corona.
            QPoint pos(sjob->parameters()["x"].toInt(), sjob->parameters()["y"].toInt());
            QRect availableRect = QApplication::desktop()->availableGeometry(pos);
            QRect menuRect = QRect(pos, menu->sizeHint());
            if (menuRect.left() < availableRect.left()) {
                menuRect.moveLeft(availableRect.left());
            } else if (menuRect.right() > availableRect.right()) {
                menuRect.moveRight(availableRect.right());
            }
            if (menuRect.top() < availableRect.top()) {
                menuRect.moveTop(availableRect.top());
            } else if (menuRect.bottom() > availableRect.bottom()) {
                menuRect.moveBottom(availableRect.bottom());
            }
            //kDebug() << "non-corona execing at: " << menuRect.topLeft();
            menu->exec(menuRect.topLeft());
        }
    }
}

void DBusSystemTrayWidget::calculateShowPosition()
{
    Plasma::Corona *corona = m_host->containment()->corona();
    QSize s(1, 1);
    QPoint pos = corona->popupPosition(this, s);
    KConfigGroup params = m_service->operationDescription("Activate");
    params.writeEntry("x", pos.x());
    params.writeEntry("y", pos.y());
    m_service->startOperationCall(params);
}

void DBusSystemTrayWidget::setIcon(const QString &iconName, const QIcon &icon)
{
    if (!iconName.isEmpty()) {
        QString name = QString("icons/") + iconName.split("-").first();
        if (Plasma::Theme::defaultTheme()->imagePath(name).isEmpty()) {
            Plasma::IconWidget::setIcon(icon);
        } else {
            setSvg(name, iconName);
            if (svg().isEmpty()) {
                Plasma::IconWidget::setIcon(icon);
            }
        }
    } else {
        Plasma::IconWidget::setIcon(icon);
    }
}

void DBusSystemTrayWidget::paint(QPainter *painter, const QStyleOptionGraphicsItem *option, QWidget *widget)
{
    Plasma::IconWidget::paint(painter, option, widget);
    if (!svg().isEmpty()) {
        int size = 0;
        if (iconSize().width() <= KIconLoader::SizeSmallMedium) {
            size = KIconLoader::SizeSmall/2;
        } else if (iconSize().width() <= KIconLoader::SizeMedium) {
            size = KIconLoader::SizeSmall/2;
        } else {
            size = KIconLoader::SizeSmall;
        }
        m_overlayIcon.paint(painter, QRect(option->rect.bottomRight() - QPoint(size, size), QSize(size, size)));
    }
}

void DBusSystemTrayWidget::setOverlayIcon(const QIcon &icon)
{
    m_overlayIcon = icon;
}

QIcon DBusSystemTrayWidget::overlayIcon() const
{
    return m_overlayIcon;
}

}

