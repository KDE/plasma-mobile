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

#include "dirmodel.h"

#include <KDirLister>
#include <KDebug>


DirModel::DirModel(QObject *parent)
    : KDirModel(parent)
{
    KMimeType::List mimeList = KMimeType::allMimeTypes();

    m_mimeTypes << "inode/directory";
    foreach (KMimeType::Ptr mime, mimeList) {
        if (mime->name().startsWith("image/")) {
            m_mimeTypes << mime->name();
        }
    }

    dirLister()->setMimeFilter(m_mimeTypes);

    QHash<int, QByteArray>roleNames;
    roleNames[Qt::DisplayRole] = "display";
    roleNames[Qt::DecorationRole] = "decoration";
    roleNames[UrlRole] = "url";
    roleNames[MimeTypeRole] = "mimeType";
    setRoleNames(roleNames);

    connect(this, SIGNAL(rowsInserted(QModelIndex,int,int)),
            this, SIGNAL(countChanged()));
    connect(this, SIGNAL(rowsRemoved(QModelIndex,int,int)),
            this, SIGNAL(countChanged()));
    connect(this, SIGNAL(modelReset()),
            this, SIGNAL(countChanged()));
}

DirModel::~DirModel()
{
}

QString DirModel::url() const
{
    return dirLister()->url().path();
}

void DirModel::setUrl(const QString& url)
{
    if (dirLister()->url().path() == url) {
        return;
    }

    dirLister()->openUrl(url);
    emit urlChanged();
}

int DirModel::indexForUrl(const QString &url) const
{
    QModelIndex index = KDirModel::indexForUrl(KUrl(url));
    return index.row();
}

QVariant DirModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid()) {
        return QVariant();
    }

    switch (role) {
    case UrlRole: {
        KFileItem item = itemForIndex(index);
        return item.url().prettyUrl();
    }
    case MimeTypeRole: {
        KFileItem item = itemForIndex(index);
        return item.mimetype();
    }
    default:
        return KDirModel::data(index, role);
    }
}

#include "dirmodel.moc"
