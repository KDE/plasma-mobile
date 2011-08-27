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
#include "completionitem.h"

#include "kdebug.h"

class CompletionModelPrivate {

public:
    QList<QObject*> items;
};


CompletionModel::CompletionModel(QObject *parent)
    : QObject(parent)
{
    d = new CompletionModelPrivate;
    populate();
}

CompletionModel::~CompletionModel()
{
    delete d;
}

QList<QObject*> CompletionModel::items()
{
    return d->items;
}


void CompletionModel::populate()
{
    kDebug() << "populating model...";
    d->items.append(new CompletionItem("Planet KDE", "http://planetkde.org", QImage(), this));
    d->items.append(new CompletionItem("Cookie Test", "http://vizZzion.org", QImage(), this));
    d->items.append(new CompletionItem("G..gle", "http://google.com", QImage(), this));
}


#include "completionmodel.moc"
