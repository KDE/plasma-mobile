/***************************************************************************
 * Copyright  2010 by Davide Bettio <davide.bettio@kdemail.net>            *
 * Copyright  2011 Marco Martin <mart@kde.org>                             *
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

#include "imagescaler.h"

#include <KStandardDirs>
#include <kdebug.h>

ImageScaler::ImageScaler(const QImage &img, QSize size)
{
    m_image = img;
    m_size = size;
}

void ImageScaler::run()
{
    QImage img = m_image.scaled(m_size, Qt::IgnoreAspectRatio, Qt::SmoothTransformation);

    const QString path = KStandardDirs::locateLocal("data", QString("plasma/activities-screenshots/%1.png").arg(m_activity));
    img.save(path, "PNG");

    emit scaled(m_activity, img);
}

void ImageScaler::setActivity(const QString &activity)
{
    m_activity = activity;
}

QString ImageScaler::activity() const
{
    return m_activity;
}

#include "imagescaler.moc"
