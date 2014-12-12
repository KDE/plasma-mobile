/***************************************************************************
 *                                                                         *
 *   Copyright 2014 Sebastian Kügler <sebas@kde.org>                       *
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

#ifndef BOOKMARKSMANAGER_H
#define BOOKMARKSMANAGER_H

#include <QObject>
#include <QQmlPropertyMap>

#include "urlmodel.h"

//class QQuickItem;

namespace AngelFish {
/**
 * @class BookmarksManager
 * @short Allows access to Bookmarks and History
 */
class BookmarksManager : public QObject
{
    Q_OBJECT

    //Q_PROPERTY(int gridUnit READ gridUnit NOTIFY gridUnitChanged)
    Q_PROPERTY(QAbstractListModel* bookmarks READ bookmarks NOTIFY bookmarksChanged)

public:

    BookmarksManager(QObject *parent = 0);
    ~BookmarksManager();

    QAbstractListModel* bookmarks();

Q_SIGNALS:
    void updated();
    void bookmarksChanged();

public Q_SLOTS:
    void reload();

private:

    //int m_longDuration;

    QAbstractListModel* m_bookmarks;
};

} // namespace

#endif //BOOKMARKSMANAGER_H

