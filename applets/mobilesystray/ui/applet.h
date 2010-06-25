/***************************************************************************
 *   applet.h                                                              *
 *                                                                         *
 *   Copyright (C) 2010 Lim Yuen Hoe <yuenhoe@hotmail.com>                 *
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

#ifndef APPLET_H
#define APPLET_H

#include <Plasma/Applet>
#include <KIcon>
#include <QGraphicsView>
#include <QHash>

namespace Plasma
{
class IconWidget;
}

class QGraphicsLinearLayout;
class QGraphicsScene;

namespace SystemTray
{

class Manager;
class Task;

class EnlargedWidget : public QGraphicsView
{
    Q_OBJECT
public:
    EnlargedWidget(QGraphicsScene *sc);

protected:
    virtual void mousePressEvent( QMouseEvent* );
};

// Define our plasma Applet
class MobileTray : public Plasma::Applet
{
    Q_OBJECT
public:
    // Basic Create/Destroy
    MobileTray(QObject *parent, const QVariantList &args);
    ~MobileTray();

    void init();
public slots:
    void addTask(SystemTray::Task* task);
    void removeTask(SystemTray::Task* task);
    void updateTask(SystemTray::Task* task);
    void enlarge();

protected:
    void mousePressEvent(QGraphicsSceneMouseEvent *event);

private:
    static Manager *m_manager;
    QGraphicsLinearLayout *layout;
    KIcon m_icon;
    QHash<QString, Plasma::IconWidget*> m_iconList;
};

}
#endif