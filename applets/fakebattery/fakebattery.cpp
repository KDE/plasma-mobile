/***************************************************************************
 *   fakebattery.cpp                                                       *
 *                                                                         *
 *   Copyright (C) 2010 Lim Yuen Hoe <yuenhoe@hotmail.com>                 *
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

#include "fakebattery.h"

#include <Plasma/Svg>

#include <QPainter>

FakeBattery::FakeBattery(QObject *parent, const QVariantList &args)
    : Plasma::Applet(parent, args), m_svg(this)
{
    m_svg.setImagePath("icons/battery");
    m_svg.setContainsMultipleImages(true);
}

FakeBattery::~FakeBattery()
{
}

void FakeBattery::init()
{
}

void FakeBattery::paintInterface(QPainter *p,
        const QStyleOptionGraphicsItem *option, const QRect &contentsRect)
{
    int minSize = qMin(contentsRect.height(), contentsRect.width());
    QRect contentsSquare = QRect(contentsRect.x() + (contentsRect.width() - minSize) / 2, contentsRect.y() + (contentsRect.height() - minSize) / 2, minSize, minSize);
    // Now we draw the applet, starting with our svg
    m_svg.resize(contentsRect.size());
    m_svg.paint(p, contentsSquare, "Battery");
    m_svg.paint(p, contentsSquare, "Fill80");
}
 
// This is the command that links your applet to the .desktop file
K_EXPORT_PLASMA_APPLET(fakebattery, FakeBattery)

#include "fakebattery.moc"