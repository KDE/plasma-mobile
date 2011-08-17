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

#include <QAction>
#include <QDir>
#include <QFileInfo>

#include <KDebug>
#include <KStandardAction>
#include <KAction>
#include <KIconLoader>

#include <Plasma/Applet>
#include <Plasma/Containment>
#include <Plasma/Corona>
#include <Plasma/PopupApplet>
#include <Plasma/WindowEffects>

#ifndef QT_NO_OPENGL
#include <QtOpenGL/QtOpenGL>
#endif

SingleView::SingleView(Plasma::Corona *corona, QWidget *parent)
    : Plasma::View(corona->containments().first(), parent),
      m_corona(corona),
      m_useGL(false)
{
    setScene(m_corona);

    setWindowTitle(i18n("Widget strip"));
    setVerticalScrollBarPolicy(Qt::ScrollBarAlwaysOff);
    setHorizontalScrollBarPolicy(Qt::ScrollBarAlwaysOff);
    setFrameStyle(QFrame::NoFrame);
}

SingleView::~SingleView()
{
   // m_containment->destroy(false);
}


void SingleView::setUseGL(const bool on)
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

bool SingleView::useGL() const
{
    return m_useGL;
}


void SingleView::resizeEvent(QResizeEvent *event)
{
    if (containment()) {
        containment()->resize(event->size());
    }
}

#include "singleview.moc"

