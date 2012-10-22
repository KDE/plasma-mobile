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

#include <QObject>
#include <QImage>
#include <Nepomuk2/Query/Result>

class History;
class CompletionModelPrivate;

class CompletionModel : public QObject
{
    Q_OBJECT

public:
    CompletionModel(QObject *parent = 0 );
    ~CompletionModel();

    QList<QObject*> items();
    QList<QObject*> filteredBookmarks();
    QList<QObject*> filteredHistory();
    History* history();

public Q_SLOTS:
    void populate();
    void setFilter(const QString &filter);

Q_SIGNALS:
    void dataChanged();

private Q_SLOTS:
    void newEntries(const QList< Nepomuk2::Query::Result > &entries);
    void entriesRemoved(const QList<QUrl> &urls);
    void finishedListing();

private:
    QList<QObject*> filteredItems(const QList<QObject*> &l);
    CompletionModelPrivate* d;
    void loadBookmarks();

};

#endif // COMPLETIONMODEL_H
