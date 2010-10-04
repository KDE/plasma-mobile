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

#include "framesvgitem_p.h"

#include <QtGui/QPainter>

#include "kdebug.h"
#include "plasma/framesvg.h"

namespace Plasma
{

FrameSvgItemMargins::FrameSvgItemMargins(Plasma::FrameSvg *frameSvg, QObject *parent)
    : QObject(parent),
      m_frameSvg(frameSvg)
{
    connect(m_frameSvg, SIGNAL(repaintNeeded()), this, SIGNAL(marginsChanged()));
}

qreal FrameSvgItemMargins::left() const
{
    return m_frameSvg->marginSize(LeftMargin);
}

qreal FrameSvgItemMargins::top() const
{
    return m_frameSvg->marginSize(TopMargin);
}

qreal FrameSvgItemMargins::right() const
{
    return m_frameSvg->marginSize(RightMargin);
}

qreal FrameSvgItemMargins::bottom() const
{
    return m_frameSvg->marginSize(BottomMargin);
}

FrameSvgItem::FrameSvgItem(QDeclarativeItem *parent)
    : QDeclarativeItem(parent)
{
    m_frameSvg = new Plasma::FrameSvg(this);
    m_margins = new FrameSvgItemMargins(m_frameSvg, this);
    setFlag(QGraphicsItem::ItemHasNoContents, false);
    connect(m_frameSvg, SIGNAL(repaintNeeded()), this, SLOT(doUpdate()));
}


FrameSvgItem::~FrameSvgItem()
{
}

void FrameSvgItem::setImagePath(const QString &path)
{
    m_frameSvg->setImagePath(path);
    update();
}

QString FrameSvgItem::imagePath() const
{
    return m_frameSvg->imagePath();
}


void FrameSvgItem::setPrefix(const QString &prefix)
{
    m_frameSvg->setElementPrefix(prefix);
    update();
}

QString FrameSvgItem::prefix() const
{
    return m_frameSvg->prefix();
}

FrameSvgItemMargins *FrameSvgItem::margins() const
{
    return m_margins;
}

void FrameSvgItem::paint(QPainter *painter, const QStyleOptionGraphicsItem *option, QWidget *widget)
{
    Q_UNUSED(option);
    Q_UNUSED(widget);

    m_frameSvg->paintFrame(painter);
}

void FrameSvgItem::geometryChanged(const QRectF &newGeometry,
                                          const QRectF &oldGeometry)
{
    m_frameSvg->resizeFrame(newGeometry.size());
    QDeclarativeItem::geometryChanged(newGeometry, oldGeometry);
}

void FrameSvgItem::doUpdate()
{
    update();
}

} // Plasma namespace

#include "framesvgitem_p.moc"
