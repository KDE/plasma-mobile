#ifndef BACKGROUNDLISTMODEL_CPP
#define BACKGROUNDLISTMODEL_CPP
/*
  Copyright (c) 2007 Paolo Capriotti <p.capriotti@gmail.com>

  This program is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 2 of the License, or
  (at your option) any later version.
*/

#include "backgroundlistmodel.h"

#include <QFile>
#include <QDir>
#include <QThreadPool>
#include <QUuid>

#include <KDebug>
#include <KFileMetaInfo>
#include <KGlobal>
#include <KIO/PreviewJob>
#include <KProgressDialog>
#include <KStandardDirs>

#include <Plasma/Package>
#include <Plasma/PackageStructure>


ImageSizeFinder::ImageSizeFinder(const QString &path, QObject *parent)
    : QObject(parent),
      m_path(path)
{
}

void ImageSizeFinder::run()
{
    QImage image(m_path);
    emit sizeFound(m_path, image.size());
}


BackgroundListModel::BackgroundListModel(Plasma::Wallpaper *listener, QObject *parent)
    : QAbstractListModel(parent),
      m_structureParent(listener),
      m_screenshotSize(320, 200),
      m_size(0,0),
      m_resizeMethod(Plasma::Wallpaper::ScaledResize)
{
    connect(&m_dirwatch, SIGNAL(deleted(QString)), this, SLOT(removeBackground(QString)));
    m_previewUnavailablePix.fill(Qt::transparent);
    //m_previewUnavailablePix = KIcon("unknown").pixmap(m_previewUnavailablePix.size());
    QHash<int, QByteArray> roleNames;
    roleNames[Qt::DisplayRole] = "display";
    roleNames[ScreenshotRole] = "screenshot";
    roleNames[AuthorRole] = "author";
    roleNames[ResolutionRole] = "resolution";
    setRoleNames(roleNames);
}

BackgroundListModel::~BackgroundListModel()
{
    qDeleteAll(m_packages);
}

void BackgroundListModel::removeBackground(const QString &path)
{
    QModelIndex index;
    while ((index = indexOf(path)).isValid()) {
        beginRemoveRows(QModelIndex(), index.row(), index.row());
        Plasma::Package *package = m_packages.at(index.row());
        m_packages.removeAt(index.row());
        delete package;
        endRemoveRows();
    }
}

void BackgroundListModel::reload()
{
    reload(QStringList());
}

void BackgroundListModel::reload(const QStringList &selected)
{
    if (!m_packages.isEmpty()) {
        beginRemoveRows(QModelIndex(), 0, m_packages.count() - 1);
        qDeleteAll(m_packages);
        m_packages.clear();
        endRemoveRows();
    }

    if (!selected.isEmpty()) {
        processPaths(selected);
    }

    const QStringList dirs = KGlobal::dirs()->findDirs("wallpaper", "");
    kDebug() << "going looking in" << dirs;
    BackgroundFinder *finder = new BackgroundFinder(m_structureParent, dirs);
    connect(finder, SIGNAL(backgroundsFound(QStringList,QString)), this, SLOT(backgroundsFound(QStringList,QString)));
    m_findToken = finder->token();
    finder->start();
}

void BackgroundListModel::backgroundsFound(const QStringList &paths, const QString &token)
{
    if (token == m_findToken) {
        processPaths(paths);
    }
}

void BackgroundListModel::processPaths(const QStringList &paths)
{
    QList<Plasma::Package *> newPackages;
    foreach (const QString &file, paths) {
        if (!contains(file) && QFile::exists(file)) {
            Plasma::PackageStructure::Ptr structure = Plasma::Wallpaper::packageStructure(m_structureParent);
            Plasma::Package *package  = new Plasma::Package(file, structure);
            if (package->isValid()) {
                newPackages << package;
            } else {
                delete package;
            }
        }
    }

    // add new files to dirwatch
    foreach (Plasma::Package *b, newPackages) {
        if (!m_dirwatch.contains(b->path())) {
            m_dirwatch.addFile(b->path());
        }
    }

    if (!newPackages.isEmpty()) {
        const int start = rowCount();
        beginInsertRows(QModelIndex(), start, start + newPackages.size());
        m_packages.append(newPackages);
        endInsertRows();
    }
    //kDebug() << t.elapsed();
}

void BackgroundListModel::addBackground(const QString& path)
{
    if (!contains(path)) {
        if (!m_dirwatch.contains(path)) {
            m_dirwatch.addFile(path);
        }
        beginInsertRows(QModelIndex(), 0, 0);
        Plasma::PackageStructure::Ptr structure = Plasma::Wallpaper::packageStructure(m_structureParent);
        Plasma::Package *pkg = new Plasma::Package(path, structure);
        m_packages.prepend(pkg);
        endInsertRows();
    }
}

QModelIndex BackgroundListModel::indexOf(const QString &path) const
{
    for (int i = 0; i < m_packages.size(); i++) {
        // packages will end with a '/', but the path passed in may not
        QString package = m_packages[i]->path();
        if (package.at(package.length() - 1) == '/') {
            package.truncate(package.length() - 1);
        }

        if (path.startsWith(package)) {
            // FIXME: ugly hack to make a difference between local files in the same dir
            // package->path does not contain the actual file name
            if ((!m_packages[i]->structure()->contentsPrefixPaths().isEmpty()) ||
                (path == m_packages[i]->filePath("preferred"))) {
                return index(i, 0);
            }
        }
    }
    return QModelIndex();
}

bool BackgroundListModel::contains(const QString &path) const
{
    return indexOf(path).isValid();
}

int BackgroundListModel::rowCount(const QModelIndex &) const
{
    return m_packages.size();
}

QSize BackgroundListModel::bestSize(Plasma::Package *package) const
{
    if (m_sizeCache.contains(package)) {
        return m_sizeCache.value(package);
    }

    const QString image = package->filePath("preferred");
    if (image.isEmpty()) {
        return QSize();
    }

    KFileMetaInfo info(image, QString(), KFileMetaInfo::TechnicalInfo);
    QSize size(info.item("http://freedesktop.org/standards/xesam/1.0/core#width").value().toInt(),
               info.item("http://freedesktop.org/standards/xesam/1.0/core#height").value().toInt());
    //backup solution if strigi does not work
    if (size.width() == 0 || size.height() == 0) {
//        kDebug() << "fall back to QImage, check your strigi";
        ImageSizeFinder *finder = new ImageSizeFinder(image);
        connect(finder, SIGNAL(sizeFound(QString,QSize)), this,
                SLOT(sizeFound(QString,QSize)));
        QThreadPool::globalInstance()->start(finder);
        size = QSize(-1, -1);
    }

    const_cast<BackgroundListModel *>(this)->m_sizeCache.insert(package, size);
    return size;
}

void BackgroundListModel::sizeFound(const QString &path, const QSize &s)
{
    QModelIndex index = indexOf(path);
    if (index.isValid()) {
        Plasma::Package *package = m_packages.at(index.row());
        m_sizeCache.insert(package, s);
        emit dataChanged(index, index);
    }
}

void BackgroundListModel::setScreenshotSize(const QSize &size)
{
    if (m_screenshotSize == size) {
        return;
    }

    m_screenshotSize = size;
    //all screenshots have to be repainted
    emit dataChanged(index(0), index(rowCount()));
}

QSize BackgroundListModel::screenshotSize() const
{
    return m_screenshotSize;
}

QVariant BackgroundListModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid()) {
        return QVariant();
    }

    if (index.row() >= m_packages.size()) {
        return QVariant();
    }

    Plasma::Package *b = package(index.row());
    if (!b) {
        return QVariant();
    }

    switch (role) {
    case Qt::DisplayRole: {
        QString title = b->metadata().name();

        if (title.isEmpty()) {
            return QFileInfo(b->filePath("preferred")).completeBaseName();
        }

        return title;
    }
    break;

    case ScreenshotRole: {
        if (m_previews.contains(b)) {
            return m_previews.value(b);
        }

        KUrl file(b->filePath("preferred"));
        if (!m_previewJobs.contains(file) && file.isValid()) {
            KFileItemList list;
            list.append(KFileItem(file, QString(), 0));
            KIO::PreviewJob* job = KIO::filePreview(list, m_screenshotSize);
            job->setIgnoreMaximumSize(true);
            connect(job, SIGNAL(gotPreview(const KFileItem&, const QPixmap&)),
                    this, SLOT(showPreview(const KFileItem&, const QPixmap&)));
            connect(job, SIGNAL(failed(const KFileItem&)),
                    this, SLOT(previewFailed(const KFileItem&)));
            const_cast<BackgroundListModel *>(this)->m_previewJobs.insert(file, QPersistentModelIndex(index));
        }

        const_cast<BackgroundListModel *>(this)->m_previews.insert(b, m_previewUnavailablePix);
        return m_previewUnavailablePix;
    }
    break;

    case AuthorRole:
        return b->metadata().author();
    break;

    case ResolutionRole:{
        QSize size = bestSize(b);

        if (size.isValid()) {
            return QString("%1x%2").arg(size.width()).arg(size.height());
        }

        return QString();
    }
    break;

    default:
        return QVariant();
    break;
    }
}

void BackgroundListModel::showPreview(const KFileItem &item, const QPixmap &preview)
{
    QPersistentModelIndex index = m_previewJobs.value(item.url());
    m_previewJobs.remove(item.url());

    if (!index.isValid()) {
        return;
    }

    Plasma::Package *b = package(index.row());
    if (!b) {
        return;
    }

    m_previews.insert(b, preview);
    //kDebug() << "preview size:" << preview.size();
    emit dataChanged(index, index);
}

void BackgroundListModel::previewFailed(const KFileItem &item)
{
    m_previewJobs.remove(item.url());
}

Plasma::Package* BackgroundListModel::package(int index) const
{
    return m_packages.at(index);
}

void BackgroundListModel::setWallpaperSize(const QSize& size)
{
    m_size = size;
}

void BackgroundListModel::setResizeMethod(Plasma::Wallpaper::ResizeMethod resizeMethod)
{
    m_resizeMethod = resizeMethod;
}

BackgroundFinder::BackgroundFinder(Plasma::Wallpaper *structureParent, const QStringList &paths)
    : QThread(structureParent),
      m_structure(Plasma::Wallpaper::packageStructure(structureParent)),
      m_paths(paths),
      m_token(QUuid().toString())
{
}

BackgroundFinder::~BackgroundFinder()
{
    wait();
}

QString BackgroundFinder::token() const
{
    return m_token;
}

void BackgroundFinder::run()
{
    //QTime t;
    //t.start();
    QSet<QString> suffixes;
    suffixes << "png" << "jpeg" << "jpg" << "svg" << "svgz";

    QStringList papersFound;
    //kDebug() << "starting with" << m_paths;

    QDir dir;
    dir.setFilter(QDir::AllDirs | QDir::Files | QDir::Hidden | QDir::Readable);
    Plasma::Package pkg(QString(), m_structure);

    int i;
    for (i = 0; i < m_paths.count(); ++i) {
        const QString path = m_paths.at(i);
        //kDebug() << "doing" << path;
        dir.setPath(path);
        const QFileInfoList files = dir.entryInfoList();
        foreach (const QFileInfo &wp, files) {
            if (wp.isDir()) {
                //kDebug() << "directory" << wp.fileName() << validPackages.contains(wp.fileName());
                const QString name = wp.fileName();
                if (name == "." || name == "..") {
                    // do nothing
                    continue;
                }

                const QString filePath = wp.filePath();
                if (QFile::exists(filePath + "/metadata.desktop")) {
                    pkg.setPath(filePath);
                    if (pkg.isValid()) {
                        papersFound << pkg.path();
                        continue;
                        //kDebug() << "gots a" << wp.filePath();
                    }
                }

                // add this to the directories we should be looking at
                m_paths.append(filePath);
            } else if (suffixes.contains(wp.suffix().toLower())) {
                //kDebug() << "     adding image file" << wp.filePath();
                papersFound << wp.filePath();
            }
        }
    }

    //kDebug() << "background found!" << papersFound.size() << "in" << i << "dirs, taking" << t.elapsed() << "ms";
    emit backgroundsFound(papersFound, m_token);
    deleteLater();
}

#include "backgroundlistmodel.moc"


#endif // BACKGROUNDLISTMODEL_CPP
