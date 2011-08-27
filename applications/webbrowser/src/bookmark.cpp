/***************************************************************************
 *                                                                         *
 *   Copyright 2011 Sebastian Kügler <sebas@kde.org>                       *
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

#include "bookmark.h"

class BookmarkPrivate {

public:
    QString name;
    QString url;
    QImage image;
};


Bookmark::Bookmark(const QString &n, const QString &u, const QImage &i, QObject *parent)
    : QObject(parent)
{
    d = new BookmarkPrivate;
    d->name = n;
    d->url = u;
    d->image = i;
}

Bookmark::~Bookmark()
{
    delete d;
}

QString Bookmark::name()
{
    return d->name;
}

QString Bookmark::url()
{
    return d->url;
}

QImage Bookmark::image()
{
    return d->image;
}

void Bookmark::setName(const QString &name)
{
    d->name = name;
}

void Bookmark::setUrl(const QString &url)
{
    d->url = url;
}

void Bookmark::setImage(const QImage &image)
{
    d->image = image;
}

#include "bookmark.moc"
