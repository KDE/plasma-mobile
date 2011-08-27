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

#ifndef COMPLETIONMODEL_H
#define COMPLETIONMODEL_H

#include "bookmark.h"

#include <QObject>
#include <QImage>

class CompletionModelPrivate;

class CompletionModel : public QObject
{
    Q_OBJECT

public:
    CompletionModel(QObject *parent = 0 );
    ~CompletionModel();

    QList<Bookmark*> data();

public Q_SLOTS:
    void populate();

Q_SIGNALS:
    void dataChanged();

private:
    CompletionModelPrivate* d;

};

#endif // BOOKMARKSMODEL_H
