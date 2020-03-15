/***************************************************************************
 *   Copyright (C) 2019 Carson Black <uhhadd@gmail.com>                    *
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

#include <QObject>
#include <QColor>
#include <QImage>
#include <QDebug>
#include <signal.h>

#include "colouraverage.h"

ColourAverage::ColourAverage(QObject* parent) : QObject(parent) {}

QColor ColourAverage::averageColour(QImage img) {
    int r = 0;
    int g = 0;
    int b = 0;
    int c = 0;

    for (int i = 0; i < img.width(); i++) {
        for (int ii = 0; ii < img.height(); ii++) {
            QRgb pix = img.pixel(i, ii);
            if (pix == 0)
                continue;

            c++;
            r += qRed(pix);
            g += qGreen(pix);
            b += qBlue(pix);
        }
    }
    r = r / c;
    g = g / c;
    b = b / c;

    QColor color = QColor::fromRgb(r,g,b);

    color.setHsv(color.hue(), color.saturation() / 4, color.value());

    return color;
}
