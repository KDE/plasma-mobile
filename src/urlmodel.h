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

#ifndef URLMODEL_H
#define URLMODEL_H

#include <QAbstractListModel>

#include "url.h"

namespace AngelFish {


class UrlModel : public QAbstractListModel
{
    Q_OBJECT
public:
    enum Roles {
        url = Qt::UserRole + 1,
        title,
        icon,
        preview,
        lastVisited,
        bookmarked
    };

    explicit UrlModel(const QString &filename, QObject *parent = 0);

    void setSourceData(UrlData *data);

    bool load();
    bool save();

    virtual QHash<int, QByteArray> roleNames() const;
    virtual int rowCount(const QModelIndex &parent) const;
    virtual QVariant data(const QModelIndex &index, int role) const;

    void update();

    UrlData fakeData();

private:
    QString key(int role) const;
    UrlData *m_data;
    QHash<int, QByteArray> m_roleNames;

    UrlData m_fakeData;

    QString m_fileName;
};

} // namespace

#endif // URLMODEL_H
