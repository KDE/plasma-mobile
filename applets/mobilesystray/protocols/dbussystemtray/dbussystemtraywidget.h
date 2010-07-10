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

#ifndef DBUSSYSTEMTRAYWIDGET_H
#define DBUSSYSTEMTRAYWIDGET_H

#include <Plasma/IconWidget>

class KJob;

namespace Plasma
{
    class Applet;
}

namespace SystemTray
{

class DBusSystemTrayWidget : public Plasma::IconWidget
{
    Q_OBJECT

public:
    DBusSystemTrayWidget(Plasma::Applet *parent, Plasma::Service *service);
    void setIcon(const QString &iconName, const QIcon &icon);

    void setItemIsMenu(bool itemIsMenu);
    bool itemIsMenu() const;

    void setOverlayIcon(const QIcon &icon);
    QIcon overlayIcon() const;

Q_SIGNALS:
    void clicked(const QPoint &pos);

protected:
    void mousePressEvent(QGraphicsSceneMouseEvent *event);
    void mouseReleaseEvent(QGraphicsSceneMouseEvent *event);
    void wheelEvent(QGraphicsSceneWheelEvent *event);
    void contextMenuEvent(QGraphicsSceneContextMenuEvent *event);
    void paint(QPainter *painter, const QStyleOptionGraphicsItem *option, QWidget *widget);

private Q_SLOTS:
    void calculateShowPosition();
    void showContextMenu(KJob *job);

private:
    Plasma::Service *m_service;
    Plasma::Applet *m_host;
    QIcon m_overlayIcon;
    bool m_itemIsMenu;
    bool m_waitingOnContextMenu;
};

}


#endif
