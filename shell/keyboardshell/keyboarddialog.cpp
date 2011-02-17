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

#include "keyboarddialog.h"

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

KeyboardDialog::KeyboardDialog(Plasma::Corona *corona, Plasma::Containment *containment, const QString &pluginName, int appletId, const QVariantList &appletArgs, QWidget *parent)
    : Plasma::Dialog(parent),
      m_applet(0),
      m_containment(0),
      m_corona(corona),
      m_direction(Plasma::Up),
      m_rotation(0)
{
    setContainment(containment);
    m_containment->setFormFactor(Plasma::Planar);
    m_containment->setLocation(Plasma::BottomEdge);
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

    setGraphicsWidget(m_applet);

    m_applet->setFlag(QGraphicsItem::ItemIsMovable, false);
    setWindowTitle(m_applet->name());
    setWindowIcon(SmallIcon(m_applet->icon()));

    connect(this, SIGNAL(sceneRectAboutToChange()), this, SLOT(updateGeometry()));
    QDesktopWidget *desktop = QApplication::desktop();
    connect(desktop, SIGNAL(resized(int )), this, SLOT(updateGeometry()));

    setFixedHeight(static_cast<Plasma::PopupApplet *>(applet())->graphicsWidget()->effectiveSizeHint(Qt::PreferredSize).height());

    hide();
    updateGeometry();
}

KeyboardDialog::~KeyboardDialog()
{
    emit storeApplet(m_applet);
}


void KeyboardDialog::setContainment(Plasma::Containment *c)
{
    if (m_containment) {
        disconnect(m_containment, 0, this, 0);
    }

    m_containment = c;
    m_containment->setScreen(0);
    updateGeometry();
}




Plasma::Applet *KeyboardDialog::applet()
{
    return m_applet;
}

Plasma::Location KeyboardDialog::location() const
{
    return m_containment->location();
}

Plasma::FormFactor KeyboardDialog::formFactor() const
{
    return m_containment->formFactor();
}

void KeyboardDialog::updateGeometry()
{
    QDesktopWidget *desktop = QApplication::desktop();
    m_containment->setGeometry(QRect(QPoint(0,0), desktop->size()));
    m_corona->setSceneRect(m_containment->geometry());
}

void KeyboardDialog::setRotation(const int degrees)
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
    m_applet->setTransform(rotationTransform);
}

int KeyboardDialog::rotation() const
{
    return m_rotation;
}

void KeyboardDialog::setDirection(const Plasma::Direction direction)
{
    if (direction == m_direction) {
        return;
    }

    m_direction = direction;

    QDesktopWidget *desktop = QApplication::desktop();
    QRect screenGeom = desktop->screenGeometry(desktop->screenNumber(this));

    screenGeom.setWidth(qMin(screenGeom.width(), (int)m_applet->effectiveSizeHint(Qt::PreferredSize).width())-300);

    switch (direction) {
    case Plasma::Down:
        setRotation(180);
        setFixedHeight(static_cast<Plasma::PopupApplet *>(applet())->graphicsWidget()->effectiveSizeHint(Qt::PreferredSize).height());
        setFixedWidth(screenGeom.width());
        move(screenGeom.left(), screenGeom.top());
        break;
    case Plasma::Left:
        setRotation(270);
        setFixedWidth(static_cast<Plasma::PopupApplet *>(applet())->graphicsWidget()->effectiveSizeHint(Qt::PreferredSize).height());
        setFixedHeight(screenGeom.height());
        move(screenGeom.right() - width(), screenGeom.top());
        break;
    case Plasma::Right:
        setRotation(90);
        setFixedWidth(static_cast<Plasma::PopupApplet *>(applet())->graphicsWidget()->effectiveSizeHint(Qt::PreferredSize).height());
        setFixedHeight(screenGeom.height());
        move(screenGeom.left(), screenGeom.top());
        break;
    case Plasma::Up:
    default:
        setRotation(0);
        setFixedHeight(static_cast<Plasma::PopupApplet *>(applet())->graphicsWidget()->effectiveSizeHint(Qt::PreferredSize).height());
        setFixedWidth(screenGeom.width());
        move(screenGeom.left(), screenGeom.height() - height());
        break;
    }

}

Plasma::Direction KeyboardDialog::direction() const
{
    return m_direction;
}

void KeyboardDialog::showEvent(QShowEvent *event)
{
    Plasma::Dialog::showEvent(event);

    //FIXME: this is an hack for the applet disabing itself in panic when doesn't immediately find a view
    Plasma::PopupApplet *pa = qobject_cast<Plasma::PopupApplet *>(m_applet);
    if (pa) {
        pa->graphicsWidget()->setEnabled(true);
    }
}

void KeyboardDialog::resizeEvent(QResizeEvent *event)
{
    Plasma::Dialog::resizeEvent(event);
    QDesktopWidget *desktop = QApplication::desktop();
    move(desktop->size().width()/2-event->size().width()/2, desktop->size().height()-event->size().height());
}

QSize KeyboardDialog::transformedSize() const
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

#include "keyboarddialog.moc"

