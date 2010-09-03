/*
 *   Copyright 2007-2008 Aaron Seigo <aseigo@kde.org>
 *   Copyright 2009 Marco Martin <notmart@gmail.com>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License version 2 as
 *   published by the Free Software Foundation
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#include "singleview.h"

#include <cmath>

#include <QAction>
#include <QApplication>
#include <QDesktopWidget>
#include <QFileInfo>
#include <QDir>


#include <KWindowSystem>
#include <KIconLoader>
#include <KCmdLineArgs>

#include <Plasma/Applet>
#include <Plasma/PopupApplet>
#include <Plasma/Corona>
#include <Plasma/Containment>
#include <Plasma/PushButton>

SingleView::SingleView(Plasma::Corona *corona, Plasma::Containment *containment, const QString &pluginName, int appletId, const QVariantList &appletArgs, QWidget *parent)
    : QGraphicsView(parent),
      m_applet(0),
      m_containment(containment),
      m_corona(corona),
      m_direction(Plasma::Up),
      m_rotation(0)
{
    setScene(m_corona);
    m_containment->setFormFactor(Plasma::Planar);
    m_containment->setLocation(Plasma::Floating);
    KWindowSystem::setType(winId(), NET::Dock);
    QFileInfo info(pluginName);
    if (!info.isAbsolute()) {
        info = QFileInfo(QDir::currentPath() + "/" + pluginName);
    }

    if (info.exists()) {
        m_applet = Plasma::Applet::loadPlasmoid(info.absoluteFilePath(), appletId, appletArgs);
    }

    if (!m_applet) {
        m_applet = Plasma::Applet::load(pluginName, appletId, appletArgs);
    }

    m_containment->addApplet(m_applet, QPointF(-1, -1), false);

    QSizeF containmentSize(m_containment->size());
    containmentSize.setHeight(qMax(containmentSize.height(), m_applet->size().height()));
    containmentSize.setWidth(containmentSize.width() + QWIDGETSIZE_MAX);
    m_containment->resize(containmentSize);
    m_applet->setPos((m_applet->id()-1)*QWIDGETSIZE_MAX, 0);

    m_applet->setFlag(QGraphicsItem::ItemIsMovable, false);
    setSceneRect(m_applet->geometry());
    setWindowTitle(m_applet->name());
    setWindowIcon(SmallIcon(m_applet->icon()));
    setVerticalScrollBarPolicy(Qt::ScrollBarAlwaysOff);
    setHorizontalScrollBarPolicy(Qt::ScrollBarAlwaysOff);
    setFrameStyle(QFrame::NoFrame);

    connect(this, SIGNAL(sceneRectAboutToChange()), this, SLOT(updateGeometry()));
    QDesktopWidget *desktop = QApplication::desktop();
    QRect screenGeom = desktop->screenGeometry(desktop->screenNumber(this));

    m_closeButton = new Plasma::PushButton();
    m_closeButton->setText(i18n("close"));
    m_closeButton->setIcon(KIcon("window-close"));
    m_corona->addItem(m_closeButton);
    connect(m_closeButton, SIGNAL(clicked()), this, SLOT(hide()));



    setFixedHeight(static_cast<Plasma::PopupApplet *>(applet())->graphicsWidget()->effectiveSizeHint(Qt::PreferredSize).height() + m_closeButton->size().height());
    setFixedWidth(screenGeom.width());
    move(screenGeom.left(), screenGeom.height() - height());

    m_closeButton->setPos(size().width() - m_closeButton->size().width(), m_applet->pos().y() - m_closeButton->size().height());

    show();
}

SingleView::~SingleView()
{
    delete m_applet;
    delete m_closeButton;
}


void SingleView::setContainment(Plasma::Containment *c)
{
    if (m_containment) {
        disconnect(m_containment, 0, this, 0);
    }

    updateGeometry();
}


void SingleView::resizeEvent(QResizeEvent *event)
{
    Q_UNUSED(event)
    updateGeometry();
    emit geometryChanged();

    QDesktopWidget *desktop = QApplication::desktop();
    QRect screenGeom = desktop->screenGeometry(desktop->screenNumber(this));

    NETExtendedStrut strut;

    switch (m_direction) {
    case Plasma::Left:
        strut.right_width = event->size().width();
        strut.right_start = screenGeom.top();
        strut.right_end = screenGeom.bottom();
        break;
    case Plasma::Right:
        strut.left_width = event->size().width();
        strut.left_start = screenGeom.top();
        strut.left_end = screenGeom.bottom();
        break;
    case Plasma::Down:
        strut.top_width = event->size().height();
        strut.top_start = screenGeom.left();
        strut.top_end = screenGeom.width();
        break;
    case Plasma::Up:
    default:
        strut.bottom_width = event->size().height();
        strut.bottom_start = screenGeom.left();
        strut.bottom_end = screenGeom.width();
        break;
    }

    KWindowSystem::setExtendedStrut(winId(), strut.left_width,
                                             strut.left_start,
                                             strut.left_end,
                                             strut.right_width,
                                             strut.right_start,
                                             strut.right_end,
                                             strut.top_width,
                                             strut.top_start,
                                             strut.top_end,
                                             strut.bottom_width,
                                             strut.bottom_start,
                                             strut.bottom_end);
}

Plasma::Applet *SingleView::applet()
{
    return m_applet;
}

Plasma::Location SingleView::location() const
{
    return m_containment->location();
}

Plasma::FormFactor SingleView::formFactor() const
{
    return m_containment->formFactor();
}

void SingleView::updateGeometry()
{
    if (!m_containment) {
        return;
    }

    kDebug() << "New applet geometry is" << m_applet->geometry();

    if (m_applet->size().toSize() != transformedSize()) {
        if (m_applet) {
            QSize size = transformedSize() - QSize(0, m_closeButton->size().height());
            m_applet->setMinimumSize(0,0);
            m_applet->setMaximumSize(size);
            m_applet->resize(size);
        }
        setSceneRect(m_applet->geometry().adjusted(0, -m_closeButton->size().height(), 0 ,0));
    }
}

void SingleView::setRotation(const int degrees)
{
    if (degrees == m_rotation) {
        return;
    }

    m_rotation = degrees;
    const double pi = 3.141593;

    const double a    = pi/180 * degrees;
    const double sina = sin(a);
    const double cosa = cos(a);

    QTransform rotationTransform(cosa, sina, -sina, cosa, 0, 0);
    setTransform(rotationTransform);
}

int SingleView::rotation() const
{
    return m_rotation;
}

void SingleView::setDirection(const Plasma::Direction direction)
{
    if (direction == m_direction) {
        return;
    }

    m_direction = direction;

    QDesktopWidget *desktop = QApplication::desktop();
    QRect screenGeom = desktop->screenGeometry(desktop->screenNumber(this));

    switch (direction) {
    case Plasma::Down:
        setRotation(180);
        setFixedHeight(static_cast<Plasma::PopupApplet *>(applet())->graphicsWidget()->effectiveSizeHint(Qt::PreferredSize).height()+m_closeButton->size().height());
        setFixedWidth(screenGeom.width());
        move(screenGeom.left(), screenGeom.top());
        break;
    case Plasma::Left:
        setRotation(270);
        setFixedWidth(static_cast<Plasma::PopupApplet *>(applet())->graphicsWidget()->effectiveSizeHint(Qt::PreferredSize).height()+m_closeButton->size().height());
        setFixedHeight(screenGeom.height());
        move(screenGeom.right() - width(), screenGeom.top());
        break;
    case Plasma::Right:
        setRotation(90);
        setFixedWidth(static_cast<Plasma::PopupApplet *>(applet())->graphicsWidget()->effectiveSizeHint(Qt::PreferredSize).height()+m_closeButton->size().height());
        setFixedHeight(screenGeom.height());
        move(screenGeom.left(), screenGeom.top());
        break;
    case Plasma::Up:
    default:
        setRotation(0);
        setFixedHeight(static_cast<Plasma::PopupApplet *>(applet())->graphicsWidget()->effectiveSizeHint(Qt::PreferredSize).height()+m_closeButton->size().height());
        setFixedWidth(screenGeom.width());
        move(screenGeom.left(), screenGeom.height() - height());
        break;
    }

    m_closeButton->setPos(transformedSize().width() - m_closeButton->size().width(), m_applet->pos().y() - m_closeButton->size().height());
}

Plasma::Direction SingleView::direction() const
{
    return m_direction;
}

QSize SingleView::transformedSize() const
{
    switch (m_direction) {
    case Plasma::Left:
    case Plasma::Right:
        return QSize(size().height(), size().width());
        break;
    case Plasma::Down:
    case Plasma::Up:
    default:
        return size();
        break;
    }
}

#include "singleview.moc"

