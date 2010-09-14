/*
 *   Copyright 2010 Marco Martin <mart@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2, or
 *   (at your option) any later version.
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

#include "declarativeframesvg_p.h"

#include <QtGui/QPainter>

#include "kdebug.h"
#include "plasma/framesvg.h"

namespace Plasma
{

DeclarativeFrameSvg::DeclarativeFrameSvg(QDeclarativeItem *parent)
    : QDeclarativeItem(parent)
{
    m_frameSvg = new Plasma::FrameSvg(this);
    setFlag(QGraphicsItem::ItemHasNoContents, false);
    connect(m_frameSvg, SIGNAL(repaintNeeded()), this, SLOT(update()));
}


DeclarativeFrameSvg::~DeclarativeFrameSvg()
{
}

void DeclarativeFrameSvg::setImagePath(const QString &path)
{
    m_frameSvg->setImagePath(path);
    update();
}

QString DeclarativeFrameSvg::imagePath() const
{
    return m_frameSvg->imagePath();
}


void DeclarativeFrameSvg::setPrefix(const QString &prefix)
{
    m_frameSvg->setElementPrefix(prefix);
    update();
}

QString DeclarativeFrameSvg::prefix() const
{
    return m_frameSvg->prefix();
}

void DeclarativeFrameSvg::paint(QPainter *painter, const QStyleOptionGraphicsItem *option, QWidget *widget)
{
    Q_UNUSED(option);
    Q_UNUSED(widget);

    m_frameSvg->paintFrame(painter);
}

void DeclarativeFrameSvg::geometryChanged(const QRectF &newGeometry,
                              const QRectF &oldGeometry)
{
    Q_UNUSED(oldGeometry);
    m_frameSvg->resizeFrame(newGeometry.size());
}

} // Plasma namespace

#include "declarativeframesvg_p.moc"
