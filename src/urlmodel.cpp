/*
    Copyright (C) 2013 Mark Gaiser <markg85@gmail.com>

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License along
    with this program; if not, write to the Free Software Foundation, Inc.,
    51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

*/

#include "urlmodel.h"
#include <QDebug>
#include <QByteArray>

using namespace AngelFish;

UrlModel::UrlModel(QObject *parent) :
    QAbstractListModel(parent)
{
    m_roleNames.insert(url, "url");
    m_roleNames.insert(title, "title");
    m_roleNames.insert(icon, "icon");
    m_roleNames.insert(preview, "preview");
    m_roleNames.insert(lastVisited, "lastVisited");
    m_roleNames.insert(bookmarked, "bookmarked");

    m_data = fakeData();
}

void UrlModel::setSourceData(UrlData *data)
{
    if (m_data != data) {
        m_data = data;
        //modelReset();
    }
}

QHash<int, QByteArray> UrlModel::roleNames() const
{
    return m_roleNames;
}

int UrlModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    if (m_data->size() <= 0) {
        return 0;
    } else {
        return m_data->size();
    }
}

QVariant UrlModel::data(const QModelIndex &index, int role) const
{
    if (index.isValid()) {

        Url currentData = m_data->at(index.row());

        switch (role) {
        case url:
            return currentData.url;
        case title:
            return currentData.title;
        case icon:
            return currentData.icon;
        case preview:
            return currentData.preview;
        case lastVisited:
            return currentData.lastVisited;
        case bookmarked:
            return currentData.bookmarked;
        }
    }
    return QVariant();
}

void UrlModel::update()
{
    if (m_data->size() <= 0) {
        return;
    }

    // We always have 42 items (or weeks * num of days in week) so we only have to tell the view that the data changed.
    //layoutChanged();
}

UrlData* UrlModel::fakeData()
{
    UrlData data;
    {
        Url u;
        u.url = QUrl("http://vizZion.org");
        u.title = QStringLiteral("Sebas' Blog");
        u.icon = QImage();
        u.preview = QImage();
        u.bookmarked = true;
        u.lastVisited = QDateTime::currentDateTime();
        data << u;
    }
    {
        Url u;
        u.url = QUrl("http://lwn.net");
        u.title = QStringLiteral("Linux Weekly News");
        u.icon = QImage();
        u.preview = QImage();
        u.bookmarked = true;
        u.lastVisited = QDateTime::currentDateTime();
        data << u;
    }
    {
        Url u;
        u.url = QUrl("http://golem.de");
        u.title = QStringLiteral("Golem");
        u.icon = QImage();
        u.preview = QImage();
        u.bookmarked = true;
        u.lastVisited = QDateTime::currentDateTime();
        data << u;
    }
    {
        Url u;
        u.url = QUrl("http://planetkde.org");
        u.title = QStringLiteral("PlanetKDE");
        u.icon = QImage();
        u.preview = QImage();
        u.bookmarked = true;
        u.lastVisited = QDateTime::currentDateTime();
        data << u;
    }

    return &data;
}

