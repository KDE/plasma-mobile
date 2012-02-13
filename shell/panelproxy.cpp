/***************************************************************************
 *   Copyright 2011 Marco Martin <mart@kde.org>                            *
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

#include "panelproxy.h"

#include <QDBusConnection>
#include <QDBusMessage>
#include <QDBusPendingCall>
#include <QDBusServiceWatcher>
#include <QDeclarativeItem>
#include <QGraphicsObject>
#include <QGraphicsView>
#include <QGraphicsWidget>
#include <QLayout>
#include <QTimer>

#include <KWindowSystem>

#include <Plasma/Corona>

#include "panelshadows.h"
#include "plasmaapp.h"

uint PanelProxy::s_numItems = 0;

PanelProxy::PanelProxy(QObject *parent)
    : QObject(parent),
      m_acceptsFocus(false),
      m_activeWindow(false),
      m_windowStrip(false),
      m_windowSelected(false)
{
    m_panel = new QGraphicsView();
    m_panel->setHorizontalScrollBarPolicy(Qt::ScrollBarAlwaysOff);
    m_panel->setVerticalScrollBarPolicy(Qt::ScrollBarAlwaysOff);
    m_panel->installEventFilter(this);
    m_panel->setAutoFillBackground(false);
    m_panel->viewport()->setAutoFillBackground(false);
    m_panel->setAttribute(Qt::WA_TranslucentBackground);
    m_panel->setAttribute(Qt::WA_OpaquePaintEvent);
    m_panel->setAttribute(Qt::WA_NoSystemBackground);
    m_panel->viewport()->setAttribute(Qt::WA_OpaquePaintEvent);
    m_panel->viewport()->setAttribute(Qt::WA_NoSystemBackground);
    m_panel->viewport()->setAttribute(Qt::WA_TranslucentBackground);
    m_panel->setWindowFlags(m_panel->windowFlags() | Qt::FramelessWindowHint | Qt::CustomizeWindowHint);
    m_panel->setFrameShape(QFrame::NoFrame);
    KWindowSystem::setOnAllDesktops(m_panel->winId(), true);
    unsigned long state = NET::Sticky | NET::StaysOnTop | NET::KeepAbove | NET::SkipTaskbar | NET::SkipPager;
    KWindowSystem::setState(m_panel->effectiveWinId(), state);
    KWindowSystem::setType(m_panel->effectiveWinId(), NET::Dock);
    PlasmaApp::self()->panelShadows()->addWindow(m_panel);

    QDBusServiceWatcher *kwinWatch = new QDBusServiceWatcher("org.kde.kwin", QDBusConnection::sessionBus(), QDBusServiceWatcher::WatchForRegistration, this);
    connect(kwinWatch, SIGNAL(serviceRegistered(QString)), this, SLOT(updateWindowListArea()));
    connect(this, SIGNAL(windowStripChanged()), SLOT(slotWindowStripChanged()));
}

PanelProxy::~PanelProxy()
{
    delete m_panel;
}

QGraphicsObject *PanelProxy::mainItem() const
{
    return m_mainItem.data();
}

void PanelProxy::setMainItem(QGraphicsObject *mainItem)
{
    if (m_mainItem.data() != mainItem) {
        if (m_mainItem) {
            m_mainItem.data()->setParent(mainItem->parent());
            m_mainItem.data()->removeEventFilter(this);
            m_mainItem.data()->setY(0);
        }
        m_mainItem = mainItem;
        if (mainItem) {
            mainItem->setParentItem(0);
            mainItem->setParent(this);
        }

        mainItem->installEventFilter(this);

        //if this is called in Compenent.onCompleted we have to wait a loop the item is added to a scene
        QTimer::singleShot(0, this, SLOT(syncMainItem()));
        emit mainItemChanged();
    }
}

void PanelProxy::syncMainItem()
{
    if (!m_mainItem) {
        return;
    }

    //not have a scene? go up in the hyerarchy until we find something with a scene
    QGraphicsScene *scene = m_mainItem.data()->scene();
    if (!scene) {
        QObject *parent = m_mainItem.data();
        while ((parent = parent->parent())) {
            QGraphicsObject *qo = qobject_cast<QGraphicsObject *>(parent);
            if (qo) {
                scene = qo->scene();
                if (scene) {
                    scene->addItem(m_mainItem.data());
                    ++s_numItems;
                    //negative y positive x, in another direction compared to corona offscreen widgets
                    m_mainItem.data()->setY(-10000*s_numItems);
                    m_mainItem.data()->setY(10000*s_numItems);
                    break;
                }
            }
        }
    }

    if (!scene) {
        return;
    }

    m_panel->setScene(scene);

    m_panel->setMinimumSize(QSize(m_mainItem.data()->boundingRect().width(), m_mainItem.data()->boundingRect().height()));
    m_panel->setMaximumSize(m_panel->minimumSize());

    QRectF itemGeometry(QPointF(m_mainItem.data()->x(), m_mainItem.data()->y()),
                        QSizeF(m_mainItem.data()->boundingRect().size()));

    m_panel->setSceneRect(itemGeometry);
}

bool PanelProxy::isVisible() const
{
    return m_panel->isVisible();
}

void PanelProxy::setVisible(const bool visible)
{
    if (m_panel->isVisible() != visible) {
        m_panel->setVisible(visible);
        if (visible) {
            m_panel->setVisible(visible);
            m_panel->raise();
        }
        emit visibleChanged();
    }
}

int PanelProxy::x() const
{
    return m_panel->pos().x();
}

void PanelProxy::setX(int x)
{
    m_panel->move(x, m_panel->pos().y());
}

int PanelProxy::y() const
{
    return m_panel->pos().y();
}

void PanelProxy::setY(int y)
{
    m_panel->move(m_panel->pos().x(), y);
}

bool PanelProxy::acceptsFocus() const
{
    return m_acceptsFocus;
}

void PanelProxy::setAcceptsFocus(bool accepts)
{
    if (accepts == m_acceptsFocus) {
        return;
    }

    m_acceptsFocus = accepts;

    if (accepts) {
        m_panel->setAttribute(Qt::WA_X11DoNotAcceptFocus, false);

        m_panel->activateWindow();
        KWindowSystem::forceActiveWindow(m_panel->effectiveWinId());
    } else {
        unsigned long state = NET::Sticky | NET::StaysOnTop | NET::KeepAbove;
        KWindowSystem::setState(m_panel->effectiveWinId(), state);
        m_panel->setAttribute(Qt::WA_X11DoNotAcceptFocus, true);
    }

    emit acceptsFocusChanged();
}

bool PanelProxy::isActiveWindow() const
{
    return m_activeWindow;
}

QRectF PanelProxy::windowListArea() const
{
    return m_windowListArea;
}

void PanelProxy::setWindowListArea(const QRectF &rectf)
{
    const QRect rect = rectf.toRect();
    if (m_windowListArea != rect) {
        m_windowListArea = rect;
    }
}

void PanelProxy::updateWindowListArea()
{
    kDebug() << "updating with" << m_windowListArea;
    if (m_windowListArea.isEmpty()) {
        return;
    }
}

bool PanelProxy::eventFilter(QObject *watched, QEvent *event)
{
    //Panel
    if (watched == m_panel && event->type() == QEvent::Move) {
        QMoveEvent *me = static_cast<QMoveEvent *>(event);
        if (me->oldPos().x() != me->pos().x()) {
            emit xChanged();
        }
        if (me->oldPos().y() != me->pos().y()) {
            emit yChanged();
        }
    } else if (watched == m_panel && event->type() == QEvent::WindowActivate) {
        m_activeWindow = true;
        emit activeWindowChanged();
    } else if (watched == m_panel && event->type() == QEvent::WindowDeactivate) {
        m_activeWindow = false;
        emit activeWindowChanged();
    } else if (watched == m_panel && event->type() == QEvent::Close) {
        event->ignore();
        return true;

    //Main item
    } else if (watched == m_mainItem.data() &&
               (event->type() == QEvent::Resize || event->type() == QEvent::Move)) {
        syncMainItem();
    }
    return false;
}

bool PanelProxy::isWindowStripEnabled() const
{
    return m_windowStrip;
}

void PanelProxy::setWindowStripEnabled(bool enable)
{
    m_windowStrip = enable;
    emit windowStripChanged();
}

void PanelProxy::slotWindowStripChanged()
{
    if (m_windowStrip) {
        m_windowSelected = false;
        QDBusMessage msg = QDBusMessage::createMethodCall("org.kde.kwin", "/TabBox", "org.kde.kwin", "openEmbedded");
        QList<QVariant> vars;
        vars.append(QVariant::fromValue<qulonglong>(m_panel->winId()));
        vars.append(QVariant::fromValue<QPoint>(QPoint(0, 50)));
        vars.append(QVariant::fromValue<QSize>(m_windowListArea.size()));
        vars.append(QVariant::fromValue<int>(Qt::AlignLeft));
        vars.append(QVariant::fromValue<int>(Qt::AlignBottom));
        msg.setArguments(vars);
        QDBusConnection::sessionBus().asyncCall(msg);
        QDBusConnection::sessionBus().connect("org.kde.kwin", "/TabBox", "org.kde.kwin", "itemSelected", this, SLOT(windowSelected()));
    } else {
        QDBusMessage msg = QDBusMessage::createMethodCall("org.kde.kwin", "/TabBox", "org.kde.kwin", m_windowSelected ? "accept" : "reject");
        QDBusConnection::sessionBus().asyncCall(msg);
        QDBusConnection::sessionBus().disconnect("org.kde.kwin", "/TabBox", "org.kde.kwin", "itemSelected", this, SLOT(windowSelected()));
    }
}

void PanelProxy::windowSelected()
{
    m_windowSelected = true;
    m_mainItem.data()->setProperty("state", "Hidden");
}


#include "panelproxy.moc"

