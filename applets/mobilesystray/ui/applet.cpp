/***************************************************************************
 *   applet.cpp                                                            *
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

#include "applet.h"

#include <QGraphicsLinearLayout>
#include <QGraphicsScene>
#include <QDesktopWidget>
#include <QRect>

#include <plasma/widgets/iconwidget.h>
#include <plasma/dataenginemanager.h>

#include "../core/manager.h"
#include "../core/task.h"
#include "enlargedoverlay.h"

namespace SystemTray
{

EnlargedWidget::EnlargedWidget(QGraphicsScene *sc)
    : QGraphicsView(sc)
{
    const QDesktopWidget desktop;
    QRect size = desktop.availableGeometry(this);
    resize(size.width(), size.height());
    setWindowFlags(Qt::Popup);
    setAttribute(Qt::WA_TranslucentBackground, true);
    setStyleSheet("background: transparent; border: none");
    setAlignment(Qt::AlignTop);
    move(0,0);
}

void EnlargedWidget::mousePressEvent(QMouseEvent* e)
{
    if (e->y() > 100)
        hide();
}

Manager *MobileTray::m_manager = 0;

MobileTray::MobileTray(QObject *parent, const QVariantList &args)
    : Plasma::Applet(parent, args),
    m_icon("document")
{
    if (!m_manager) {
        m_manager = new SystemTray::Manager();
    }
    setBackgroundHints(DefaultBackground);
    layout = new QGraphicsLinearLayout(Qt::Horizontal, this);
    resize(50,50);
}


MobileTray::~MobileTray()
{
    if (hasFailedToLaunch()) {
        // Do some cleanup here
    } else {
        // Save settings
    }
}

void MobileTray::init()
{
    m_manager->loadApplets(this);

    connect(m_manager, SIGNAL(taskAdded(SystemTray::Task*)),
            this, SLOT(addTask(SystemTray::Task*)));
    connect(m_manager, SIGNAL(taskChanged(SystemTray::Task*)),
            this, SLOT(updateTask(SystemTray::Task*)));
    connect(m_manager, SIGNAL(taskRemoved(SystemTray::Task*)),
            this, SLOT(removeTask(SystemTray::Task*)));
/*
    QStringList applets = m_manager->applets(0);
    if (!applets.contains("org.kde.networkmanagement")) {
        m_manager->addApplet("org.kde.networkmanagement", this);
    }

    if (!applets.contains("notifier")) {
        m_manager->addApplet("notifier", this);
    }

    if (!applets.contains("notifications")) {
        m_manager->addApplet("notifications", this);
    }

    if (!applets.contains("battery")) {
        Plasma::DataEngineManager *engines = Plasma::DataEngineManager::self();
        Plasma::DataEngine *power = engines->loadEngine("powermanagement");
        if (power) {
            const QStringList &batteries = power->query("Battery")["sources"].toStringList();
            if (!batteries.isEmpty()) {
                m_manager->addApplet("battery", this);
            }
        }
        engines->unloadEngine("powermanagement");
    }
*/

    foreach(Task *task, m_manager->tasks()) {
      Plasma::IconWidget *ic = new Plasma::IconWidget(task->icon(), "", this);
      m_iconList.insert(task->typeId(), ic);
      connect(ic, SIGNAL(clicked()), this, SLOT(enlarge()));
      layout->addItem(ic);
    }
}

void MobileTray::addTask(SystemTray::Task* task)
{
    Plasma::IconWidget *ic = new Plasma::IconWidget(task->icon(), "", this);
    m_iconList.insert(task->typeId(), ic);
    connect(ic, SIGNAL(clicked()), this, SLOT(enlarge()));
    layout->addItem(ic);
}

void MobileTray::removeTask(SystemTray::Task* task)
{
    Plasma::IconWidget *ic = m_iconList.take(task->typeId());
    layout->removeItem(ic);
    delete ic;
}

void MobileTray::updateTask(SystemTray::Task* task)
{
    removeTask(task);
    addTask(task);
}

void MobileTray::enlarge()
{
    QGraphicsScene *sc = new QGraphicsScene();
    EnlargedWidget *view = new EnlargedWidget(sc);
    EnlargedOverlay *a = new EnlargedOverlay(m_manager->tasks(), view->size(), this);
    sc->addItem(a);
    view->show();
}

void MobileTray::mousePressEvent(QGraphicsSceneMouseEvent*)
{
    enlarge();
}


// This is the command that links your applet to the .desktop file
K_EXPORT_PLASMA_APPLET(mobilesystemtray, MobileTray)

}

#include "applet.moc"