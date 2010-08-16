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

namespace SystemTray
{

class Manager;
class Task;


/**
 * Main applet of the mobile version of the system tray.
 *
 * It has two modes - "active" and "passive", and switches between them depending on the
 * width of the applet. "Active" mode is meant to be interactive and all icons are visible
 * together with an additional cancel icon that hints to the parent to shrink it back to "passive"
 * mode using the "shrinkRequested()" signal. "Passive" mode is meant to be non-interactive and
 * some icons are hidden.
 *
 * The tray differentiates between two kinds of icons - fixed and cyclic. Fixed icons are always
 * shown irregardless of mode, while cyclic icons can be hidden in "passive" mode.
 */
class MobileTray : public Plasma::Containment
{
    Q_OBJECT
public:
    // Basic Create/Destroy
    MobileTray(QObject *parent, const QVariantList &args);
    ~MobileTray();

    void init();

    void constraintsEvent(Plasma::Constraints constraints);

signals:
    void shrinkRequested(); // signal to parent to shrink the tray to "passive" mode

public slots:
    void addTask(SystemTray::Task* task);
    void removeTask(SystemTray::Task* task);
    void updateTask(SystemTray::Task* task);

protected:
    enum Mode { PASSIVE, ACTIVE };
    Mode m_mode;
    void paint(QPainter *painter, const QStyleOptionGraphicsItem *option,
               QWidget *widget = 0);
    void resizeEvent (QGraphicsSceneResizeEvent * event);
    void resizeContents();

protected slots:
    void toActive();
    void toPassive();
    void addTrayApplet(Plasma::Applet* ap);

private:
    static const int WIDTH_THRESHOLD = 500;     // beyond which the tray is considered expanded/shrunken
    void showWidget(QGraphicsWidget *w, int index = -1);
    void hideWidget(QGraphicsWidget *w);
    static Manager *m_manager;
    static const int MAXCYCLIC = 2;             // Maximum number of cyclic icons to show in "passive" mode
    Plasma::FrameSvg *m_background;
    QGraphicsLinearLayout *m_layout;
    QList<QString> m_fixedList;                 // List of icon names that should be "fixed"
    QHash<SystemTray::Task*, QGraphicsWidget*> m_cyclicIcons; // list of visible cyclic icons
    QHash<SystemTray::Task*, QGraphicsWidget*> m_fixedIcons;  // list of fixed icons
    QHash<SystemTray::Task*, QGraphicsWidget*> m_hiddenIcons; // list of hidden cyclic icons
    QQueue<SystemTray::Task*> m_recentQueue;
    Plasma::IconWidget *m_cancel;
    Plasma::ScrollWidget *m_scrollWidget;
    Plasma::PopupApplet *m_notificationsApplet;
    QGraphicsWidget *m_mainWidget;              // area in the scrollwidget that contains the tray icons
    bool initDone;
};

}
#endif