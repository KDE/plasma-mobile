/***************************************************************************
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

#include "browsermanager.h"

#include <QDebug>
#include <QUrl>

#include <KDirWatch>

using namespace AngelFish;

BrowserManager::BrowserManager(QObject *parent)
    : QObject(parent),
      m_bookmarks(0),
      m_history(0)
{
}

BrowserManager::~BrowserManager()
{
    history()->save();
    bookmarks()->save();
}

void BrowserManager::reload()
{
    qDebug() << "BookmarksManager::reload()";
}

UrlModel* BrowserManager::bookmarks()
{
//     qDebug() << "BookmarksManager::bookmarks()";
    if (!m_bookmarks) {
        m_bookmarks = new UrlModel(QStringLiteral("bookmarks.json"), this);
        m_bookmarks->load();
    }
    return m_bookmarks;
}

UrlModel* BrowserManager::history()
{
//     qDebug() << "BrowserManager::history()";
    if (!m_history) {
        m_history = new UrlModel(QStringLiteral("history.json"), this);
        m_history->load();
    }
    return m_history;
}

void BrowserManager::addBookmark(const QVariantMap& bookmarkdata)
{
    qDebug() << "Add bookmark";
    qDebug() << "      data: " << bookmarkdata;
    bookmarks()->add(QJsonObject::fromVariantMap(bookmarkdata));
}

void BrowserManager::removeBookmark(const QString& url)
{
    bookmarks()->remove(url);
}

void BrowserManager::addToHistory(const QVariantMap& pagedata)
{
//     qDebug() << "Add History";
//     qDebug() << "      data: " << pagedata;
    history()->add(QJsonObject::fromVariantMap(pagedata));
    emit historyChanged();
}

void BrowserManager::removeFromHistory(const QString& url)
{
    history()->remove(url);
    emit historyChanged();
}

QString BrowserManager::urlFromUserInput(const QString& input)
{
    QUrl url = QUrl::fromUserInput(input);
    return url.toString();
}

