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
    m_mode(PASSIVE), m_notificationsApplet(0), initDone(false)
{
    if (!m_manager) {
        m_manager = new SystemTray::Manager();
    }

    m_background = new Plasma::FrameSvg(this);
    m_background->setImagePath("widgets/translucentbackground");
    m_background->setEnabledBorders(Plasma::FrameSvg::AllBorders);

    // list of applets to "always show"
    m_fixedList << "notifications" << "org.kde.networkmanagement" << "battery" << "notifier";

    m_scrollWidget = new Plasma::ScrollWidget(this);
    m_scrollWidget->setHorizontalScrollBarPolicy(Qt::ScrollBarAlwaysOff);

    QGraphicsWidget *outsideWidget = new QGraphicsWidget(m_scrollWidget);
    QGraphicsLinearLayout* outsidelayout = new QGraphicsLinearLayout(Qt::Horizontal, outsideWidget);
    m_scrollWidget->setWidget(outsideWidget);
    outsideWidget->setLayout(outsidelayout);

    // put a widget inside the scrollwidget's widget
    // - so it can be resized independantly of the scrollwidget
    m_mainWidget = new QGraphicsWidget(this);
    m_mainWidget->setSizePolicy(QSizePolicy(QSizePolicy::Fixed, QSizePolicy::Fixed));
    outsidelayout->addItem(m_mainWidget);

    m_layout = new QGraphicsLinearLayout(Qt::Horizontal, m_mainWidget);
    m_mainWidget->setLayout(m_layout);

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
    if (formFactor() != Plasma::Horizontal && formFactor() != Plasma::Vertical) {
        setFormFactor(Plasma::Horizontal);
    }

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

void MobileTray::saveContents(KConfigGroup &group) const
{
    Q_UNUSED(group)

    //we skip the default Contaiment save, we don't want to directly save applets
    //another option by the way is to get rid of the plasmoid protocol and just load plasmoids as standard applets
}

void MobileTray::restoreContents(KConfigGroup &group)
{
    Q_UNUSED(group)
    //purposefully broken as saveContents
}

void MobileTray::resizeContents() {
    int totalItems = m_fixedIcons.size() + m_cyclicIcons.size();
    if (m_mode == ACTIVE) {
        totalItems += m_hiddenIcons.size() + 1;
    }
    int contentsHeight = size().height() - 10;
    int totalWidth = contentsHeight * totalItems;
    m_mainWidget->setPreferredSize(totalWidth, contentsHeight);
}

void MobileTray::resizeEvent(QGraphicsSceneResizeEvent* event)
{
    m_background->resizeFrame(event->newSize());
    m_scrollWidget->resize(event->newSize());
    m_scrollWidget->setPreferredSize(event->newSize());
    resizeContents();
    if (initDone) { // only do the following if init() is done - else will crash!
        if (event->newSize().width() > WIDTH_THRESHOLD && m_mode == PASSIVE) {
            toActive();
        }
        if (event->newSize().width() < WIDTH_THRESHOLD && m_mode == ACTIVE) {
            toPassive();
        }
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
            // FIXME: still not too pretty..
            Task* key = m_recentQueue.dequeue();
            QGraphicsWidget *old = m_cyclicIcons.take(key);
            m_hiddenIcons.insert(key, old);
            if (m_mode == PASSIVE) { // no need to hide if we're in ACTIVE mode
                hideWidget(old);
            }
        }

        ic->setSizePolicy(QSizePolicy(QSizePolicy::MinimumExpanding, QSizePolicy::MinimumExpanding));
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
        delete ic;
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