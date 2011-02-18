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
#include <KIconLoader>
#include <KWindowSystem>

#include <plasma/widgets/iconwidget.h>
#include <plasma/widgets/scrollwidget.h>
#include <plasma/dataenginemanager.h>
#include <plasma/containment.h>
#include <plasma/framesvg.h>
#include <Plasma/Dialog>
#include <Plasma/Corona>
#include "../core/manager.h"
#include "../core/task.h"
#include "../protocols/dbussystemtray/dbussystemtraywidget.h"

namespace SystemTray
{

Manager *MobileTray::m_manager = 0;

MobileTray::MobileTray(QObject *parent, const QVariantList &args)
    : Plasma::Containment(parent, args),
      m_mode(PASSIVE),
      m_notificationsApplet(0),
      m_appSwitcherDialog(0),
      initDone(false)
{
    if (!m_manager) {
        m_manager = new SystemTray::Manager();
    }

    m_background = new Plasma::FrameSvg(this);
    m_background->setImagePath("widgets/translucentbackground");
    m_background->setEnabledBorders(Plasma::FrameSvg::AllBorders);

    // list of applets to "always show"
    m_fixedList << "notifications" << "org.kde.fakebattery" << "org.kde.fakesignal" << "digital-clock";

    m_scrollWidget = new Plasma::ScrollWidget(this);
    m_scrollWidget->setHorizontalScrollBarPolicy(Qt::ScrollBarAlwaysOff);

    m_mainWidget = new QGraphicsWidget(this);
    m_layout = new QGraphicsLinearLayout(Qt::Horizontal, m_mainWidget);
    m_scrollWidget->setWidget(m_mainWidget);
    m_mainWidget->setLayout(m_layout);

    connect(this, SIGNAL(appletAdded(Plasma::Applet*,const QPointF&)),
            this, SLOT(addTrayApplet(Plasma::Applet*)));

    // use a timer to avoid repeated resizing
    m_resizeTimer = new QTimer(this);
    m_resizeTimer->setSingleShot(true);
    connect(m_resizeTimer, SIGNAL(timeout()), this, SLOT(resizeContents()));
}


MobileTray::~MobileTray()
{
    if (m_appSwitcherDialog && m_appSwitcherDialog->graphicsWidget()) {
        delete m_appSwitcherDialog->graphicsWidget();
    }

    // stop listening to the manager
    disconnect(m_manager, 0, this, 0);

    foreach (Task *task, m_manager->tasks()) {
        // we don't care about the task updates anymore
        disconnect(task, 0, this, 0);

        // delete our widget (if any); while we're still kicking
        delete task->widget(this, false);
    }

    // TODO: delete m_manager when we can?
}

void MobileTray::init()
{
    if (formFactor() != Plasma::Horizontal && formFactor() != Plasma::Vertical) {
        setFormFactor(Plasma::Horizontal);
    }

    foreach(Task *task, m_manager->tasks()) {
        addTask(task);
    }

    m_cancel = new Plasma::IconWidget(KIcon("dialog-cancel"), "", this);
    m_cancel->setSvg("widgets/arrows", "left-arrow");

    // request the mobile shell to do a shrink when clicked
    connect(m_cancel, SIGNAL(clicked()), this, SIGNAL(shrinkRequested()));
    m_cancel->setPreferredSize(m_cancel->size().width(), 100);
    m_cancel->setSizePolicy(QSizePolicy(QSizePolicy::Fixed, QSizePolicy::Fixed));
    m_cancel->hide();

    connect(m_manager, SIGNAL(taskAdded(SystemTray::Task*)),
            this, SLOT(addTask(SystemTray::Task*)));
    connect(m_manager, SIGNAL(taskChanged(SystemTray::Task*)),
            this, SLOT(updateTask(SystemTray::Task*)));
    connect(m_manager, SIGNAL(taskRemoved(SystemTray::Task*)),
            this, SLOT(removeTask(SystemTray::Task*)));

    if (size().width() > WIDTH_THRESHOLD) {
        toActive();
    }
    initDone = true;
}

void MobileTray::constraintsEvent(Plasma::Constraints constraints)
{
    if (constraints & Plasma::LocationConstraint) {
        Plasma::FrameSvg::EnabledBorders borders = Plasma::FrameSvg::AllBorders;

        switch (location()) {
        case Plasma::LeftEdge:
            borders ^= Plasma::FrameSvg::LeftBorder;
            break;
        case Plasma::RightEdge:
            borders ^= Plasma::FrameSvg::RightBorder;
            break;
        case Plasma::TopEdge:
            borders ^= Plasma::FrameSvg::TopBorder;
            break;
        case Plasma::BottomEdge:
            borders ^= Plasma::FrameSvg::BottomBorder;
            break;
        default:
            break;
        }

        m_background->setEnabledBorders(borders);
        qreal left, top, right, bottom;
        m_background->getMargins(left, top, right, bottom);
        setContentsMargins(left, top, right, bottom);
    }
}

void MobileTray::resizeContents() {
    // Somewhat less ugly now, but still looks kinda funny..
    int iconHeight = size().height() - 15;

    m_mainWidget->setPreferredHeight(iconHeight);
    // enlarge each applet
    foreach (QGraphicsWidget* w, m_fixedIcons) {
        w->setPreferredSize(iconHeight, iconHeight);
    }
    foreach (QGraphicsWidget* w, m_cyclicIcons) {
        w->setPreferredSize(iconHeight, iconHeight);
    }
    foreach (QGraphicsWidget* w, m_hiddenIcons) {
        w->setPreferredSize(iconHeight, iconHeight);
    }
    m_scrollWidget->show();
}

void MobileTray::resizeEvent(QGraphicsSceneResizeEvent* event)
{
    m_background->resizeFrame(event->newSize());

    // resizing the contents seems slow, asynchronous, and thus jerky and potentially problematic,
    // so we avoid resizing them continuously..
    m_resizeTimer->start(500);
    m_scrollWidget->hide(); // hide the contents during transition to mask our lazy resizing
    m_scrollWidget->setPreferredSize(event->newSize());
    m_scrollWidget->resize(event->newSize());

    if (initDone) { // only do the following if init() is done - else will crash!
        if (event->newSize().width() > WIDTH_THRESHOLD && m_mode == PASSIVE) {
            toActive();
        }
        if (event->newSize().width() < WIDTH_THRESHOLD && m_mode == ACTIVE) {
            toPassive();
        }
    }
}

// hide a tray icon
void MobileTray::hideWidget(QGraphicsWidget *w)
{
    w->hide();
    m_layout->removeItem(w);
}

// unhide/show a tray icon at a particular index
void MobileTray::showWidget(QGraphicsWidget *w, int index)
{
    w->show();
    if (index == -1) {
      m_layout->insertItem(m_layout->count(), w);
    } else {
      m_layout->insertItem(index, w);
    }
}

// create plasmoidtasks out of applets added to the containment
void MobileTray::addTrayApplet(Plasma::Applet* applet)
{
    //treat the appswitcher in a different way: it's wise?
    if (!m_appSwitcherDialog && applet->pluginName() == "org.kde.appswitcher") {
        applet->setParentItem(0);
        corona()->addOffscreenWidget(applet);
        m_appSwitcherDialog = new Plasma::Dialog();
        m_appSwitcherDialog->setGraphicsWidget(applet);
        KWindowSystem::setType(m_appSwitcherDialog->winId(), NET::Dock);
        m_appSwitcherDialog->show();
        applet->setMaximumSize(KIconLoader::SizeLarge, KIconLoader::SizeMedium);
    } else {
        m_manager->addApplet(applet, this);
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
            // FIXME: still not too pretty..
            Task* key = m_recentQueue.dequeue();
            QGraphicsWidget *old = m_cyclicIcons.take(key);
            m_hiddenIcons.insert(key, old);
            if (m_mode == PASSIVE) { // no need to hide if we're in ACTIVE mode
                hideWidget(old);
            }
        }

        ic->setSizePolicy(QSizePolicy(QSizePolicy::Fixed, QSizePolicy::Fixed));
        ic->setParent(this);

        DBusSystemTrayWidget *d = qobject_cast<DBusSystemTrayWidget*>(ic);
        if (d) {
            //d->setIcon("", task->icon());
            d->setItemIsMenu(false);
        }

        if (isFixed) {
            showWidget(ic, m_fixedIcons.size()); // FIXME: this will reverse the order of applets loaded from config
            m_fixedIcons.insert(task, ic);
        } else {
            showWidget(ic);
            m_cyclicIcons.insert(task, ic);
            m_recentQueue.enqueue(task);
        }
        resizeContents();
    }
}

void MobileTray::removeTask(SystemTray::Task* task)
{
    QGraphicsWidget *ic = 0;
    if (m_cyclicIcons.contains(task)) {
        // TODO: might want to replace with something from m_hiddenIcons
        ic = m_cyclicIcons.take(task);
        m_recentQueue.removeOne(task);
    } else if (m_fixedIcons.contains(task)) {
        ic = m_fixedIcons.take(task);
    } else if (m_hiddenIcons.contains(task)) {
        ic = m_hiddenIcons.take(task);
    }
    if (ic) {
        m_layout->removeItem(ic);
        //plasmoids are already deleted

        if (task->widgetsByHost().contains(this)) {
            delete ic;
        }
    }
    resizeContents();
}

void MobileTray::updateTask(SystemTray::Task* task)
{
    if (!task->isEmbeddable(this)) {
        return;
    }
    QGraphicsWidget *ic = 0;
    if (m_hiddenIcons.contains(task)) { // unhide!
        if (m_cyclicIcons.size() >= MAXCYCLIC) {
            // evict something
            Task* key = m_recentQueue.dequeue();
            QGraphicsWidget *old = m_cyclicIcons.take(key);
            m_hiddenIcons.insert(key, old);
            if (m_mode == PASSIVE) { // no need to hide if we're in ACTIVE mode
                hideWidget(old);
            }
        }
        ic = m_hiddenIcons.take(task);
        m_cyclicIcons.insert(task, ic);
        m_recentQueue.enqueue(task);
        if (m_mode == PASSIVE) { // if mode is ACTIVE, it's already being shown
            showWidget(ic);
        }
    } else {
        if (!m_cyclicIcons.contains(task) && !m_fixedIcons.contains(task)) {
            addTask(task); // maybe something became embeddable?
        }
    }
}
void MobileTray::toPassive()
{
    if (m_mode == ACTIVE) {
        m_mode = PASSIVE;
        if (m_notificationsApplet) {
            m_notificationsApplet->hidePopup();
        }
        foreach (QGraphicsWidget * w, m_hiddenIcons) {
            hideWidget(w);
        }
        hideWidget(m_cancel);
//        resizeContents();
    }
}

void MobileTray::toActive()
{
    if (m_mode == PASSIVE) {
        m_mode = ACTIVE;
        foreach (QGraphicsWidget * w, m_hiddenIcons) {
            showWidget(w);
        }
        showWidget(m_cancel, 0);
        if (m_notificationsApplet) {
            m_notificationsApplet->showPopup();
        }
//        resizeContents();
    }
}

void MobileTray::paint(QPainter *painter, const QStyleOptionGraphicsItem *option,
                           QWidget *widget)
{
    Q_UNUSED(option);
    Q_UNUSED(widget);

    m_background->paintFrame(painter);
}

// This is the command that links your applet to the .desktop file
K_EXPORT_PLASMA_APPLET(mobilesystemtray, MobileTray)

}

#include "applet.moc"