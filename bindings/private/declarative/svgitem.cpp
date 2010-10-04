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

#include "svgitem_p.h"

#include <QtGui/QPainter>

#include "kdebug.h"
#include "plasma/svg.h"

namespace Plasma
{

SvgItem::SvgItem(QDeclarativeItem *parent)
    : QDeclarativeItem(parent)
{
    m_svg = new Plasma::Svg(this);
    setFlag(QGraphicsItem::ItemHasNoContents, false);
    connect(m_svg, SIGNAL(repaintNeeded()), this, SLOT(update()));
}


SvgItem::~SvgItem()
{
}

void SvgItem::setImagePath(const QString &path)
{
    m_svg->setImagePath(path);
    update();
}

QString SvgItem::imagePath() const
{
    return m_svg->imagePath();
}


void SvgItem::setElementId(const QString &elementID)
{
    m_svg->setContainsMultipleImages(!elementID.isNull());

    m_elementID = elementID;
    update();
}

QString SvgItem::elementId() const
{
    return m_elementID;
}

void SvgItem::paint(QPainter *painter, const QStyleOptionGraphicsItem *option, QWidget *widget)
{
    Q_UNUSED(option);
    Q_UNUSED(widget);

    m_svg->paint(painter, boundingRect(), m_elementID);
}

} // Plasma namespace

#include "svgitem_p.moc"
