/***************************************************************************
 *   Copyright 2006-2008 Aaron Seigo <aseigo@kde.org>                      *
 *   Copyright 2009 Marco Martin <notmart@gmail.com>                       *
 *   Copyright 2010 Alexis Menard <menard@kde.org>                         *
 *   Copyright 2010 Artur Duque de Souza <asouza@kde.org>                  *
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

#include "mobview.h"
#include "mobcorona.h"
#include "plasmaapp.h"
#include "keyboard_interface.h"

#include <QAction>
#include <QCoreApplication>
#include <QDBusConnection>

#include <KWindowSystem>

#include <Plasma/Applet>
#include <Plasma/PopupApplet>
#include <Plasma/Corona>
#include <Plasma/Containment>

#ifndef QT_NO_OPENGL
#include <QtOpenGL/QtOpenGL>
#endif

MobView::MobView(Plasma::Containment *containment, int uid, QWidget *parent)
    : Plasma::View(containment, uid, parent),
      m_useGL(false),
      m_direction(Plasma::Up),
      m_rotation(0)
{
    setFocusPolicy(Qt::NoFocus);
    connectContainment(containment);
    setOptimizationFlags(QGraphicsView::DontSavePainterState);
    setHorizontalScrollBarPolicy(Qt::ScrollBarAlwaysOff);
    setVerticalScrollBarPolicy(Qt::ScrollBarAlwaysOff);
    setFrameStyle(0);
    setViewportUpdateMode(QGraphicsView::BoundingRectViewportUpdate);
    setAttribute(Qt::WA_TranslucentBackground, false);

    setTrackContainmentChanges(false);

    QAction *a = new QAction(this);
    addAction(a);
    a->setShortcut(QKeySequence("Ctrl+Shift+L"));
    connect(a, SIGNAL(triggered()), this, SLOT(rotateCounterClockwise()));

    a = new QAction(this);
    addAction(a);
    a->setShortcut(QKeySequence("Ctrl+Shift+R"));
    connect(a, SIGNAL(triggered()), this, SLOT(rotateClockwise()));
//     m_keyboard = new LocalPlasmaKeyboardInterface("org.kde.plasma-keyboardcontainer", "/App",
//                                       QDBusConnection::sessionBus());
//     m_keyboard->call("hide");
}

MobView::~MobView()
{
}

void MobView::setUseGL(const bool on)
{
#ifndef QT_NO_OPENGL
    if (on) {
      QGLWidget *glWidget = new QGLWidget;
      glWidget->setAutoFillBackground(false);
      setViewport(glWidget);
    }
#endif
    m_useGL = on;
}

bool MobView::useGL() const
{
    return m_useGL;
}

void MobView::connectContainment(Plasma::Containment *containment)
{
    if (!containment) {
        return;
    }

    connect(containment, SIGNAL(activate()), this, SIGNAL(containmentActivated()));
    connect(this, SIGNAL(sceneRectAboutToChange()), this, SLOT(updateGeometry()));
}

void MobView::setContainment(Plasma::Containment *c)
{
    if (containment()) {
        disconnect(containment(), 0, this, 0);
    }

    Plasma::View::setContainment(c);
    connectContainment(c);
    updateGeometry();
}

void MobView::drawBackground(QPainter *painter, const QRectF &rect)
{
    painter->fillRect(rect.toAlignedRect(), Qt::black);
}


bool MobView::event(QEvent *event)
{
    if (event->type() == QEvent::WindowActivate) {
        setFocus();
    }
    return Plasma::View::event(event);
}

void MobView::resizeEvent(QResizeEvent *event)
{
    Q_UNUSED(event)
    updateGeometry();
    emit geometryChanged();
}

Plasma::Location MobView::location() const
{
    return containment()->location();
}

Plasma::FormFactor MobView::formFactor() const
{
    return containment()->formFactor();
}

void MobView::setRotation(const int degrees)
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

int MobView::rotation() const
{
    return m_rotation;
}

void MobView::setDirection(const Plasma::Direction direction)
{
    if (direction == m_direction) {
        return;
    }

    int angle;
    int start = rotation();
    QString directionName;

    switch (direction) {
    case Plasma::Down:
        angle = 180;
        directionName = "down";
        break;
    case Plasma::Left:
        if (start < 180) {
            start = 360;
        }
        angle = 270;
        directionName = "left";
        break;
    case Plasma::Right:
        angle = 90;
        directionName = "right";
        break;
    case Plasma::Up:
    default:
        if (start > 180) {
            start = -90;
        }
        angle = 0;
        directionName = "up";
        break;
    }

    m_direction = direction;

    PlasmaApp::self()->containmentsTransformingChanged(true);
    QPropertyAnimation *animation = new QPropertyAnimation(this, "rotation", this);
    animation->setEasingCurve(QEasingCurve::InOutQuad);
    animation->setDuration(300);
    animation->setStartValue(start);
    animation->setEndValue(angle);

    animation->start(QAbstractAnimation::DeleteWhenStopped);

    connect(animation, SIGNAL(finished()), this, SLOT(animationFinished()));
//     m_keyboard->call("setDirection", directionName);
}

void MobView::animationFinished()
{
    PlasmaApp::self()->containmentsTransformingChanged(false);

    emit geometryChanged();
}

Plasma::Direction MobView::direction() const
{
    return m_direction;
}

QSize MobView::transformedSize() const
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

void MobView::rotateCounterClockwise()
{
    switch (m_direction) {
    case Plasma::Down:
        setDirection(Plasma::Right);
        break;
    case Plasma::Left:
        setDirection(Plasma::Down);
        break;
    case Plasma::Right:
        setDirection(Plasma::Up);
        break;
    case Plasma::Up:
    default:
        setDirection(Plasma::Left);
        break;
    }
}

void MobView::rotateClockwise()
{
    switch (m_direction) {
    case Plasma::Down:
        setDirection(Plasma::Left);
        break;
    case Plasma::Left:
        setDirection(Plasma::Up);
        break;
    case Plasma::Right:
        setDirection(Plasma::Down);
        break;
    case Plasma::Up:
    default:
        setDirection(Plasma::Right);
        break;
    }
}

void MobView::updateGeometry()
{
    Plasma::Containment *c = containment();
    if (!c) {
        return;
    }

    kDebug() << "New containment geometry is" << c->geometry();

    switch (c->location()) {
    case Plasma::TopEdge:
    case Plasma::BottomEdge:
        setMinimumWidth(0);
        setMaximumWidth(QWIDGETSIZE_MAX);
        setFixedHeight(c->size().height());
        emit locationChanged(this);
        break;
    case Plasma::LeftEdge:
    case Plasma::RightEdge:
        setMinimumHeight(0);
        setMaximumHeight(QWIDGETSIZE_MAX);
        setFixedWidth(c->size().width());
        emit locationChanged(this);
        break;
    //ignore changes in the main view
    default:
        break;
    }

    if (c->size().toSize() != size()) {
        c->setMaximumSize(size());
        c->setMinimumSize(size());
        c->resize(size());
    }
}

#include "mobview.moc"

