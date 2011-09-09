/*
    Copyright (C) 20111 Marco Martin <mart@kde.org>

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

#ifndef DIRMODEL_H
#define DIRMODEL_H

#include <KDirModel>


class DirModel : public KDirModel
{
    Q_OBJECT
    Q_PROPERTY(QString url READ url WRITE setUrl)

public:
    enum Roles {
        UrlRole = Qt::UserRole + 1,
        MimeTypeRole = Qt::UserRole + 2
    };

    DirModel(QObject* parent);
    virtual ~DirModel();

    void setUrl(const QString& url);
    QString url() const;

    QVariant data(const QModelIndex &index, int role) const;

    Q_INVOKABLE int indexForUrl(const QString &url) const;

private:
    QStringList m_mimeTypes;
};

#endif // DIRMODEL_H
