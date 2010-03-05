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

#include <QAction>
#include <QCoreApplication>

#include <KWindowSystem>

#include <Plasma/Applet>
#include <Plasma/PopupApplet>
#include <Plasma/Corona>
#include <Plasma/Containment>

#ifndef QT_NO_OPENGL
    #include <QtOpenGL/QtOpenGL>
#endif

MobView::MobView(Plasma::Containment *containment, int uid, QWidget *parent)
    : Plasma::View(containment, uid, parent), mUseGL(false)
{
    setFocusPolicy(Qt::NoFocus);
    connectContainment(containment);
    setOptimizationFlags(QGraphicsView::DontSavePainterState);
    setHorizontalScrollBarPolicy(Qt::ScrollBarAlwaysOff);
    setVerticalScrollBarPolicy(Qt::ScrollBarAlwaysOff);
    setFrameStyle(0);
    setViewportUpdateMode(QGraphicsView::BoundingRectViewportUpdate);
    setAttribute(Qt::WA_TranslucentBackground, false);
}

MobView::~MobView()
{
}

void MobView::setUseGL(bool on)
{
#ifndef QT_NO_OPENGL
    if (on) {
      QGLWidget *glWidget = new QGLWidget;
      glWidget->setAutoFillBackground(false);
      setViewport(glWidget);
    }
#endif
    mUseGL = on;
}

bool MobView::useGL()
{
    return mUseGL;
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

