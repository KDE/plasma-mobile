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

#include <KIcon>

#include <plasma/widgets/iconwidget.h>
#include <plasma/dataenginemanager.h>
#include <plasma/containment.h>

#include "../core/manager.h"
#include "../core/task.h"

namespace SystemTray
{

EnlargedWidget::EnlargedWidget(QGraphicsScene *sc)
    : QGraphicsView(sc), m_toolBoxActivated(false)
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
    if (e->y() > 100 && !m_toolBoxActivated) {
        hide();
    }
    QGraphicsView::mousePressEvent(e);
}

Manager *MobileTray::m_manager = 0;

MobileTray::MobileTray(QObject *parent, const QVariantList &args)
    : Plasma::Applet(parent, args),
    m_icon("document"), m_view(0), m_scene(0), m_overlay(0), m_toolbox(0)
{
    if (!m_manager) {
        m_manager = new SystemTray::Manager();
    }

    m_fixedList << "notifications" << "org.kde.networkmanagement" << "battery";

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

    QStringList applets = m_manager->applets(this);
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

    foreach(Task *task, m_manager->tasks()) {
        bool isFixed = m_fixedList.contains(task->typeId());
        if (task->isEmbeddable(this) && (isFixed || m_cyclicIcons.size() < MAXCYCLIC)) {
            Plasma::IconWidget *ic = new Plasma::IconWidget(task->icon(), "", this);
            connect(ic, SIGNAL(clicked()), this, SLOT(enlarge()));
            if (isFixed) {
                layout->insertItem(0, ic);
                m_fixedIcons.insert(task->typeId(), ic);
            } else {
                layout->addItem(ic);
                m_cyclicIcons.insert(task->typeId(), ic);
            }
        }
    }
    adjustSize();
    m_overlay = new EnlargedOverlay(m_manager->tasks(),
                                    containment()->boundingRect().size().toSize(), this);
    m_overlay->hide();

    connect(m_manager, SIGNAL(taskAdded(SystemTray::Task*)),
            this, SLOT(addTask(SystemTray::Task*)));
    connect(m_manager, SIGNAL(taskChanged(SystemTray::Task*)),
            this, SLOT(updateTask(SystemTray::Task*)));
    connect(m_manager, SIGNAL(taskRemoved(SystemTray::Task*)),
            this, SLOT(removeTask(SystemTray::Task*)));

}

void MobileTray::addTask(SystemTray::Task* task)
{
    m_overlay->addTask(task);
    bool isFixed = m_fixedList.contains(task->typeId());
    if (!isFixed && m_cyclicIcons.size() >= MAXCYCLIC) {
        Plasma::IconWidget *ic = m_cyclicIcons.take(m_cyclicIcons.keys().at(0));
        layout->removeItem(ic);
        delete ic;
    }
    Plasma::IconWidget *ic = new Plasma::IconWidget(task->icon(), "", this);
    connect(ic, SIGNAL(clicked()), this, SLOT(enlarge()));
    if (isFixed) {
        layout->insertItem(0,ic);
        m_fixedIcons.insert(task->typeId(), ic);
    } else {
        layout->addItem(ic);
        m_cyclicIcons.insert(task->typeId(), ic);
    }
    adjustSize();
}

void MobileTray::removeTask(SystemTray::Task* task)
{
    m_overlay->removeTask(task);
    Plasma::IconWidget *ic = 0;
    if (m_cyclicIcons.contains(task->typeId())) {
        ic = m_cyclicIcons.take(task->typeId());
    } else if (m_fixedIcons.contains(task->typeId())) {
        ic = m_fixedIcons.take(task->typeId());
    }
    if (ic) {
        layout->removeItem(ic);
        delete ic;
    }
}

void MobileTray::updateTask(SystemTray::Task* task)
{
    removeTask(task);
    addTask(task);
    //m_overlay->updateTask(task);
}

void MobileTray::enlarge()
{
    //removeToolBox();
    if (m_overlay) {
        m_overlay->show();
        m_overlay->setPos(0 - scenePos().x() + containment()->scenePos().x() + 50, 
                          0 - scenePos().y() + containment()->scenePos().y());
        return;
    }
    //m_scene = new QGraphicsScene();
    //m_view = new EnlargedWidget(m_scene);

    m_overlay = new EnlargedOverlay(m_manager->tasks(),
                                    containment()->boundingRect().size().toSize(), this);
    m_overlay->show();
    m_overlay->setPos(0 - scenePos().x() + containment()->scenePos().x() + 50, 
                      0 - scenePos().y() + containment()->scenePos().y());
    //connect (m_overlay, SIGNAL(showMenu(QMenu*)), this, SLOT(showOverlayToolBox(QMenu*)));

//    m_scene->addItem(m_overlay);

//    m_view->show();
}

void MobileTray::removeToolBox()
{
    if (m_toolbox) {
        m_scene->removeItem(m_toolbox);
        m_toolbox->hide();
        delete m_toolbox;
        m_toolbox = 0;
    }
}

void MobileTray::showOverlayToolBox(QMenu *m)
{
    removeToolBox();
    m_view->setToolBoxActivated(true);

    QAction *cancel = new QAction(KIcon("dialog-cancel"), i18n("Cancel"), this);
    connect(cancel, SIGNAL(triggered()), m_view, SLOT(hide()));
    m->addAction(cancel);

    m_toolbox = new OverlayToolBox("", this);
    m_scene->addItem(m_toolbox);
    m_toolbox->setPos(0,100);
    m_toolbox->resize(m_view->size().width() - 100, m_view->size().height() - 100);
    m_toolbox->setMainMenu(m);
}

void MobileTray::mousePressEvent(QGraphicsSceneMouseEvent*)
{
    enlarge();
}


// This is the command that links your applet to the .desktop file
K_EXPORT_PLASMA_APPLET(mobilesystemtray, MobileTray)

}

#include "applet.moc"