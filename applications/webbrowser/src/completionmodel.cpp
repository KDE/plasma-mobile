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

#include "completionmodel.h"

#include "kdebug.h"

class CompletionModelPrivate {

public:
    QList<Bookmark*> items;
};


CompletionModel::CompletionModel(QObject *parent)
    : QObject(parent)
{
    d = new CompletionModelPrivate;
}

CompletionModel::~CompletionModel()
{
    delete d;
}

QList<Bookmark*> CompletionModel::data()
{
    return d->items;
}


void CompletionModel::populate()
{
    kDebug() << "populating model...";
    d->items.append(new Bookmark("Planet KDE", "http://planetkde.org", QImage(), this));
    d->items.append(new Bookmark("Cookie Test", "http://vizZzion.org", QImage(), this));
    d->items.append(new Bookmark("G..gle", "http://google.com", QImage(), this));
}


#include "completionmodel.moc"
