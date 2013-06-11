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
#include <KIO/PreviewJob>
#include <KImageCache>


DirModel::DirModel(QObject *parent)
    : KDirModel(parent),
      m_screenshotSize(180, 120)
{
    KMimeType::List mimeList = KMimeType::allMimeTypes();

    m_mimeTypes << "inode/directory";
    foreach (KMimeType::Ptr mime, mimeList) {
        if (mime->name().startsWith(QLatin1String("image/"))) {
            m_mimeTypes << mime->name();
        }
    }

    //TODO: configurable mime filter
    //dirLister()->setMimeFilter(m_mimeTypes);

    QHash<int, QByteArray>roleNames;
    roleNames[Qt::DisplayRole] = "display";
    roleNames[Qt::DecorationRole] = "decoration";
    roleNames[UrlRole] = "url";
    roleNames[MimeTypeRole] = "mimeType";
    roleNames[Thumbnail] = "thumbnail";
    setRoleNames(roleNames);

    m_previewTimer = new QTimer(this);
    m_previewTimer->setSingleShot(true);
    connect(m_previewTimer, SIGNAL(timeout()),
            this, SLOT(delayedPreview()));

    //using the same cache of the engine, they index both by url
    m_imageCache = new KImageCache("plasma_engine_preview", 10485760);

    connect(this, SIGNAL(rowsInserted(QModelIndex,int,int)),
            this, SIGNAL(countChanged()));
    connect(this, SIGNAL(rowsRemoved(QModelIndex,int,int)),
            this, SIGNAL(countChanged()));
    connect(this, SIGNAL(modelReset()),
            this, SIGNAL(countChanged()));
}

DirModel::~DirModel()
{
    delete m_imageCache;
}

QString DirModel::url() const
{
    return dirLister()->url().prettyUrl();
}

void DirModel::setUrl(const QString& url)
{
    if (url.isEmpty()) {
        return;
    }
    if (dirLister()->url().path() == url) {
        dirLister()->updateDirectory(url);
        return;
    }

    beginResetModel();
    dirLister()->openUrl(url);
    endResetModel();
    emit urlChanged();
}

int DirModel::indexForUrl(const QString &url) const
{
    QModelIndex index = KDirModel::indexForUrl(KUrl(url));
    return index.row();
}

QVariantMap DirModel::get(int i) const
{
    QModelIndex modelIndex = index(i, 0);

    KFileItem item = itemForIndex(modelIndex);
    QString url = item.url().prettyUrl();
    QString mimeType = item.mimetype();

    QVariantMap ret;
    ret.insert("url", QVariant(url));
    ret.insert("mimeType", QVariant(mimeType));

    return ret;
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
    case Thumbnail: {
        KFileItem item = itemForIndex(index);
        QImage preview = QImage(m_screenshotSize, QImage::Format_ARGB32_Premultiplied);

        if (m_imageCache->findImage(item.url().prettyUrl(), &preview)) {
            return preview;
        }

        m_previewTimer->start(100);
        const_cast<DirModel *>(this)->m_filesToPreview[item.url()] = QPersistentModelIndex(index);
    }
    default:
        return KDirModel::data(index, role);
    }
}

void DirModel::delayedPreview()
{
    QHash<KUrl, QPersistentModelIndex>::const_iterator i = m_filesToPreview.constBegin();

    KFileItemList list;

    while (i != m_filesToPreview.constEnd()) {
        KUrl file = i.key();
        QPersistentModelIndex index = i.value();


        if (!m_previewJobs.contains(file) && file.isValid()) {
            list.append(KFileItem(file, QString(), 0));
            m_previewJobs.insert(file, QPersistentModelIndex(index));
        }

        ++i;
    }

    if (list.size() > 0) {
        KIO::PreviewJob* job = KIO::filePreview(list, m_screenshotSize);
        job->setIgnoreMaximumSize(true);
        kDebug() << "Created job" << job;
        connect(job, SIGNAL(gotPreview(KFileItem,QPixmap)),
                this, SLOT(showPreview(KFileItem,QPixmap)));
        connect(job, SIGNAL(failed(KFileItem)),
                this, SLOT(previewFailed(KFileItem)));
    }

    m_filesToPreview.clear();
}

void DirModel::showPreview(const KFileItem &item, const QPixmap &preview)
{
    QPersistentModelIndex index = m_previewJobs.value(item.url());
    m_previewJobs.remove(item.url());

    if (!index.isValid()) {
        return;
    }

    m_imageCache->insertImage(item.url().prettyUrl(), preview.toImage());
    //kDebug() << "preview size:" << preview.size();
    emit dataChanged(index, index);
}

void DirModel::previewFailed(const KFileItem &item)
{
    m_previewJobs.remove(item.url());
}

#include "dirmodel.moc"
