/*
 *   Copyright 2011 Marco Martin <notmart@gmail.com>
 *   Copyright 2010 Alexis Menard <menard@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License as published by
 *   the Free Software Foundation; either version 2 of the License, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details.
 *
 *   You should have received a copy of the GNU General Public License
 *   along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 */


#include "cachingeffect.h"
#include <QPainter>
#include <QTimer>



CachingEffect::CachingEffect(QObject *parent)
    : QGraphicsEffect(parent)
{
    m_discardTimer = new QTimer(this);
    m_discardTimer->setSingleShot(true);
    connect(m_discardTimer, SIGNAL(timeout()), this, SLOT(discardCache()));
}

void CachingEffect::draw(QPainter *p)
{
    QPoint point;
    m_cachedPixmap = sourcePixmap(Qt::DeviceCoordinates, &point);
    //maybe we are in a view with save and restore disabled..
    p->setCompositionMode(QPainter::CompositionMode_Source);

    p->drawPixmap(point, m_cachedPixmap);
    p->setCompositionMode(QPainter::CompositionMode_SourceOver);
    m_discardTimer->start(10*1000);
}

QPixmap CachingEffect::cachedPixmap() const
{
    return m_cachedPixmap;
}


void CachingEffect::discardCache()
{
    m_cachedPixmap = QPixmap();
}

#include "cachingeffect.moc"
