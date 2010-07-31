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
#include <Plasma/PopupApplet>
#include <Plasma/Containment>
#include <QHash>
#include <QQueue>

namespace Plasma
{
class IconWidget;
class ScrollWidget;
class FrameSvg;
}

class QGraphicsLinearLayout;
class QSignalMapper;

namespace SystemTray
{

class Manager;
class Task;

class MobileTray : public Plasma::Containment
{
    Q_OBJECT
public:
    // Basic Create/Destroy
    MobileTray(QObject *parent, const QVariantList &args);
    ~MobileTray();

    void init();

signals:
    void shrinkRequested();

public slots:
    void addTask(SystemTray::Task* task);
    void removeTask(SystemTray::Task* task);
    void updateTask(SystemTray::Task* task);
    void toActive();
    void toPassive();

protected:
    //reimp from Contaiment
    void saveContents(KConfigGroup &group) const;
    void restoreContents(KConfigGroup &group);
    enum Mode { PASSIVE, ACTIVE };
    Mode m_mode;
    void paint(QPainter *painter, const QStyleOptionGraphicsItem *option,
               QWidget *widget = 0);
    void resizeEvent (QGraphicsSceneResizeEvent * event);
    void resizeContents();

private:
    static const int WIDTH_THRESHOLD = 500; // beyond which the tray is considered expanded/shrunken
    void showWidget(QGraphicsWidget *w, int index = -1);
    void hideWidget(QGraphicsWidget *w);
    static Manager *m_manager;
    static const int MAXCYCLIC = 3;
    Plasma::FrameSvg m_background;
    QGraphicsLinearLayout *m_layout;
    QList<QString> m_fixedList;
    QHash<SystemTray::Task*, QGraphicsWidget*> m_cyclicIcons;
    QHash<SystemTray::Task*, QGraphicsWidget*> m_fixedIcons;
    QHash<SystemTray::Task*, QGraphicsWidget*> m_hiddenIcons;
    QQueue<SystemTray::Task*> m_recentQueue;
    Plasma::IconWidget *m_cancel;
    Plasma::ScrollWidget *m_scrollWidget;
    Plasma::PopupApplet *m_notificationsApplet;
    QGraphicsWidget *m_mainWidget;
    bool initDone;
};

}
#endif