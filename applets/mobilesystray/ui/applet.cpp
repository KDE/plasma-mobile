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
#include <QGraphicsSceneResizeEvent>
#include <QSignalMapper>

#include <KIcon>

#include <plasma/widgets/iconwidget.h>
#include <plasma/widgets/scrollwidget.h>
#include <plasma/dataenginemanager.h>
#include <plasma/containment.h>
#include <plasma/framesvg.h>
#include "../core/manager.h"
#include "../core/task.h"
#include "../protocols/dbussystemtray/dbussystemtraywidget.h"

namespace SystemTray
{

Manager *MobileTray::m_manager = 0;

MobileTray::MobileTray(QObject *parent, const QVariantList &args)
    : Plasma::Containment(parent, args),
    m_mode(PASSIVE), m_notificationsApplet(0)
{
    if (!m_manager) {
        m_manager = new SystemTray::Manager();
    }

    m_background.setImagePath("widgets/translucentbackground");
    m_background.setEnabledBorders(Plasma::FrameSvg::AllBorders);

    m_mapper = new QSignalMapper();

    // list of applets to "always show"
    m_fixedList << "notifications" << "org.kde.networkmanagement" << "battery" << "notifier";

    m_scrollWidget = new Plasma::ScrollWidget(this);
    m_scrollWidget->setHorizontalScrollBarPolicy(Qt::ScrollBarAlwaysOff);

    QGraphicsWidget *m = new QGraphicsWidget(m_scrollWidget);
    m_scrollWidget->setWidget(m);

    m_layout = new QGraphicsLinearLayout(Qt::Horizontal, m);
    m->setLayout(m_layout);

    // FIXME: attempt to center applets - but doesn't seem to quite work
    m_layout->insertStretch(0);
    m_layout->addStretch();
}


MobileTray::~MobileTray()
{
    // TODO: some cleanup?
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
        addTask(task);
    }

    // TODO: a better cancel button at a better location...
    m_cancel = new Plasma::IconWidget(KIcon("dialog-cancel"), "", this);
    m_cancel->setSvg("widgets/arrows", "left-arrow");
    // request the mobile shell to do a shrink when clicked
    connect(m_cancel, SIGNAL(clicked()), this, SIGNAL(shrinkRequested()));
    m_cancel->setPreferredSize(m_cancel->size().width(), 100);
    //m_cancel->setSizePolicy (QSizePolicy(QSizePolicy::Fixed, QSizePolicy::MinimumFixed));
    m_cancel->hide();

    connect(m_manager, SIGNAL(taskAdded(SystemTray::Task*)),
            this, SLOT(addTask(SystemTray::Task*)));
    connect(m_manager, SIGNAL(taskChanged(SystemTray::Task*)),
            this, SLOT(updateTask(SystemTray::Task*)));
    connect(m_manager, SIGNAL(taskRemoved(SystemTray::Task*)),
            this, SLOT(removeTask(SystemTray::Task*)));

}

void MobileTray::resizeWidget(QObject* w)
{
    resizeWidget(qobject_cast<QGraphicsWidget*>(w));
}

void MobileTray::resizeWidget(QGraphicsWidget* w)
{
    int size = m_mode == PASSIVE ? 40 : 100;
    w->setPreferredSize(size, size);
}

void MobileTray::resizeEvent(QGraphicsSceneResizeEvent* event)
{
    m_background.resizeFrame(event->newSize());
    m_scrollWidget->widget()->resize(event->newSize());
    m_scrollWidget->resize(event->newSize());
    if (event->newSize().width() > WIDTH_THRESHOLD && m_mode == PASSIVE) {
        enlarge();
    }
    if (event->newSize().width() < WIDTH_THRESHOLD && m_mode == ACTIVE) {
        shrink();
    }
}

void MobileTray::hideWidget(QGraphicsWidget *w)
{
    w->hide();
    m_layout->removeItem(w);
}

void MobileTray::showWidget(QGraphicsWidget *w, int index)
{
    w->show();
    if (index == -1) {
      m_layout->insertItem(m_layout->count() - 1, w);
    } else {
      m_layout->insertItem(index, w);
    }
}


void MobileTray::addTask(SystemTray::Task* task)
{
    if (task->isEmbeddable(this)) {
        bool isFixed = m_fixedList.contains(task->typeId());
        QGraphicsWidget *ic = task->widget(this, true);
        if (task->typeId() == "notifications") {
            m_notificationsApplet = qobject_cast<Plasma::PopupApplet*>(ic);
        }

        if (!ic) {
            return;
        } else if (!isFixed && m_cyclicIcons.size() >= MAXCYCLIC) {
            // "Evict" an old item to the hidden list
            // FIXME: This is no good - doesn't evict the least recent :(
            Task* key = m_cyclicIcons.keys().at(0);
            QGraphicsWidget *old = m_cyclicIcons.take(key);
            m_hiddenIcons.insert(key, old);
            if (m_mode == PASSIVE) { // no need to hide if we're in ACTIVE mode
                hideWidget(old);
            }
        }

        //ic->setSizePolicy (QSizePolicy(QSizePolicy::Fixed, QSizePolicy::Fixed));
        resizeWidget(ic);
        ic->setParent(this);

        DBusSystemTrayWidget *d = qobject_cast<DBusSystemTrayWidget*>(ic);
        if (d) {
            //d->setIcon("", task->icon());
            d->setItemIsMenu(false);
        }

        if (isFixed) {
            showWidget(ic, 1);
            m_fixedIcons.insert(task, ic);
        } else {
            showWidget(ic);
            m_cyclicIcons.insert(task, ic);
        }
        m_mapper->setMapping(ic, ic);
        connect(m_mapper, SIGNAL(mapped(QObject*)), this, SLOT(resizeWidget(QObject*)));
        connect(ic, SIGNAL(changed()), m_mapper, SLOT(map()));
    }
}

void MobileTray::removeTask(SystemTray::Task* task)
{
    QGraphicsWidget *ic = 0;
    if (m_cyclicIcons.contains(task)) {
        ic = m_cyclicIcons.take(task);
    } else if (m_fixedIcons.contains(task)) {
        ic = m_fixedIcons.take(task);
    } else if (m_hiddenIcons.contains(task)) {
        ic = m_hiddenIcons.take(task);
    }
    if (ic) {
        m_layout->removeItem(ic);
        delete ic;
    }
}

void MobileTray::updateTask(SystemTray::Task* task)
{
    // FIXME: Icon changes don't seem to go through here :(
    if (!task->isEmbeddable(this)) {
        return;
    }
    QGraphicsWidget *ic = 0;
    if (m_hiddenIcons.contains(task)) { // unhide!
        if (m_cyclicIcons.size() >= MAXCYCLIC) {
            // evict something
            Task* key = m_cyclicIcons.keys().at(0);
            QGraphicsWidget *old = m_cyclicIcons.take(key);
            m_hiddenIcons.insert(key, old);
            if (m_mode == PASSIVE) { // no need to hide if we're in ACTIVE mode
                hideWidget(old);
            }
        }
        ic = m_hiddenIcons.take(task);
        m_cyclicIcons.insert(task, ic);
        resizeWidget(ic);
        if (m_mode == PASSIVE) { // if mode is ACTIVE, it's already being shown
            showWidget(ic);
        }
    } else { // not hidden, probably just need to resize
        if (m_cyclicIcons.contains(task)) {
            ic = m_cyclicIcons.value(task);
        }
        if (m_fixedIcons.contains(task)) {
            ic = m_fixedIcons.value(task);
        }
        if (ic) {
            resizeWidget(ic);
        } else { // maybe something became embeddable?
            addTask(task);
        }
    }
}
void MobileTray::shrink()
{
    if (m_mode == ACTIVE) {
        m_mode = PASSIVE;
        if (m_notificationsApplet) {
            m_notificationsApplet->hidePopup();
        }
        foreach (QGraphicsWidget * w, m_hiddenIcons) {
            resizeWidget(w);
            hideWidget(w);
        }
        foreach (QGraphicsWidget * w, m_fixedIcons) {
            resizeWidget(w);
        }
        foreach (QGraphicsWidget * w, m_cyclicIcons) {
            resizeWidget(w);
        }
        hideWidget(m_cancel);
        m_scrollWidget->widget()->resize(size());
        m_scrollWidget->resize(size());
    }
}

void MobileTray::enlarge()
{
    if (m_mode == PASSIVE) {
        m_mode = ACTIVE;
        foreach (QGraphicsWidget * w, m_fixedIcons) {
            resizeWidget(w);
        }
        foreach (QGraphicsWidget * w, m_cyclicIcons) {
            resizeWidget(w);
        }
        foreach (QGraphicsWidget * w, m_hiddenIcons) {
            resizeWidget(w);
            showWidget(w);
        }
        showWidget(m_cancel, 0);
        m_scrollWidget->widget()->resize(size());
        m_scrollWidget->resize(size());
        if (m_notificationsApplet) {
            m_notificationsApplet->showPopup();
        }
    }
}

void MobileTray::paint(QPainter *painter, const QStyleOptionGraphicsItem *option,
                           QWidget *widget)
{
    Q_UNUSED(option);
    Q_UNUSED(widget);

    m_background.paintFrame(painter);
}

void MobileTray::mousePressEvent(QGraphicsSceneMouseEvent*)
{
    enlarge();
}


// This is the command that links your applet to the .desktop file
K_EXPORT_PLASMA_APPLET(mobilesystemtray, MobileTray)

}

#include "applet.moc"