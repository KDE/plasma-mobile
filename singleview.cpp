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
#include <QCoreApplication>
#include <QFileInfo>
#include <QDir>

#include <KWindowSystem>
#include <KIconLoader>
#include <KCmdLineArgs>

#include <Plasma/Applet>
#include <Plasma/PopupApplet>
#include <Plasma/Corona>
#include <Plasma/Containment>

SingleView::SingleView(Plasma::Corona *corona, Plasma::Containment *containment, const QString &pluginName, int appletId, const QVariantList &appletArgs, QWidget *parent)
    : QGraphicsView(parent),
      m_applet(0),
      m_containment(containment),
      m_corona(corona)
{
    setScene(m_corona);
    m_containment->setFormFactor(Plasma::Planar);
    m_containment->setLocation(Plasma::Floating);
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
}

SingleView::~SingleView()
{
    delete m_applet;
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

    if (m_applet->size().toSize() != size()) {
        if (m_applet) {
            m_applet->resize(size());
        }
        setSceneRect(m_applet->geometry());
    }
}

#include "singleview.moc"

