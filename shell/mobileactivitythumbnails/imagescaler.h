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

#ifndef IMAGESCALER_H
#define IMAGESCALER_H

#include <QImage>
#include <QObject>
#include <QRunnable>
#include <QSize>

class ImageScaler : public QObject, public QRunnable
{
    Q_OBJECT

public:
    ImageScaler(const QImage &img, QSize size);
    void run();
    void setActivity(const QString &string);
    QString activity() const;

Q_SIGNALS:
    void scaled(const QString &activity, const QImage &image);

private:
    QImage m_image;
    QSize m_size;
    QString m_activity;
};

#endif
