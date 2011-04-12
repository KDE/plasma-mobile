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

#ifndef CACHINGEFFECT_H
#define CACHINGEFFECT_H

#include <QGraphicsEffect>


class CachingEffect : public QGraphicsEffect
{
    Q_OBJECT
public :
    CachingEffect(QObject *parent = 0);

    void draw(QPainter *p);

    QPixmap cachedPixmap() const;

protected Q_SLOTS:
    void discardCache();

private:
    QPixmap m_cachedPixmap;
    QTimer *m_discardTimer;
};

#endif
