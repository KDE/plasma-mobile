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
 *                                                                         *
 ***************************************************************************/

#ifndef BOOKMARKSMANAGER_H
#define BOOKMARKSMANAGER_H

#include <QObject>
#include <QQmlPropertyMap>

#include "urlmodel.h"

namespace AngelFish {
/**
 * @class BookmarksManager
 * @short Access to Bookmarks and History. This is a singleton for
 * administration and access to the various models and browser-internal
 * data.
 */
class BrowserManager : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QAbstractListModel* bookmarks READ bookmarks NOTIFY bookmarksChanged)
    Q_PROPERTY(QAbstractListModel* history READ history NOTIFY historyChanged)

public:

    BrowserManager(QObject *parent = 0);
    ~BrowserManager();

    UrlModel* bookmarks();
    UrlModel* history();

    Q_INVOKABLE static QString urlFromUserInput(const QString &input);


Q_SIGNALS:
    void updated();
    void bookmarksChanged();
    void historyChanged();

public Q_SLOTS:
    void reload();

    void addBookmark(const QVariantMap &bookmarkdata);
    void removeBookmark(const QString &url);

    void addToHistory(const QVariantMap &pagedata);
    void removeFromHistory(const QString &url);

private:

    UrlModel* m_bookmarks;
    UrlModel* m_history;
};

} // namespace

#endif //BOOKMARKSMANAGER_H

