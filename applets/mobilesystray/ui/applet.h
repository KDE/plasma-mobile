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
#include <Plasma/Containment>
#include <QHash>

namespace Plasma
{
class IconWidget;
class ScrollWidget;
}

class QGraphicsLinearLayout;

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
    void resize ( const QSizeF & size );

signals:
    void shrinkRequested();

public slots:
    void addTask(SystemTray::Task* task);
    void removeTask(SystemTray::Task* task);
    void updateTask(SystemTray::Task* task);
    void shrink();
    void enlarge();

protected:
    enum Mode { PASSIVE, ACTIVE};
    Mode m_mode;
    void mousePressEvent(QGraphicsSceneMouseEvent *event);
    void resizeEvent (QGraphicsSceneResizeEvent * event);

private:
    void showWidget(QGraphicsWidget *w, int index = -1);
    void hideWidget(QGraphicsWidget *w);
    static Manager *m_manager;
    static const int MAXCYCLIC = 3;
    QGraphicsLinearLayout *m_layout;
    QList<QString> m_fixedList;
    QHash<QString, QGraphicsWidget*> m_cyclicIcons;
    QHash<QString, QGraphicsWidget*> m_fixedIcons;
    QHash<QString, QGraphicsWidget*> m_hiddenIcons;
    Plasma::IconWidget *m_cancel;
    Plasma::ScrollWidget *m_scrollWidget;
};

}
#endif