/*
  Copyright (c) 2007 by Paolo Capriotti <p.capriotti@gmail.com>
  Copyright (c) 2007 by Aaron Seigo <aseigo@kde.org>
  Copyright (c) 2008 by Alexis Ménard <darktears31@gmail.com>
  Copyright (c) 2008 by Petri Damsten <damu@iki.fi>

  This program is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 2 of the License, or
  (at your option) any later version.
*/

#include "mobileimage.h"

#include <QAction>
#include <QApplication>
#include <QPainter>
#include <QFile>
#include <QEasingCurve>
#include <QPropertyAnimation>
#include <QTimer>

#include <KDebug>
#include <KDirSelectDialog>
#include <KDirWatch>
#include <KFileDialog>
#include <KRandom>
#include <KStandardDirs>
#include <KIO/Job>
#include <krun.h>
#include <knewstuff3/downloaddialog.h>

#include <Plasma/Theme>
#include "backgroundlistmodel.h"

K_EXPORT_PLASMA_WALLPAPER(mobileimage, MobileImage)

MobileImage::MobileImage(QObject *parent, const QVariantList &args)
    : Plasma::Wallpaper(parent, args),
      m_wallpaperPackage(0),
      m_model(0),
      m_openImageAction(0)
{
}

MobileImage::~MobileImage()
{
}

void MobileImage::init(const KConfigGroup &config)
{
    calculateGeometry();

    m_resizeMethod = (ResizeMethod)config.readEntry("wallpaperposition", (int)ScaledResize);
    m_wallpaper = config.readEntry("wallpaper", QString());
    if (m_wallpaper.isEmpty()) {
        useSingleImageDefaults();
    }

    m_usersWallpapers = config.readEntry("userswallpapers", QStringList());

    setSingleImage();
    setContextualActions(QList<QAction*>());
}

void MobileImage::useSingleImageDefaults()
{
    m_wallpaper = Plasma::Theme::defaultTheme()->wallpaperPath();
    int index = m_wallpaper.indexOf("/contents/images/");
    if (index > -1) { // We have file from package -> get path to package
        m_wallpaper = m_wallpaper.left(index);
    }
}

void MobileImage::save(KConfigGroup &config)
{
    config.writeEntry("wallpaperposition", (int)m_resizeMethod);
    config.writeEntry("wallpaper", m_wallpaper);
    config.writeEntry("userswallpapers", m_usersWallpapers);
}

void MobileImage::calculateGeometry()
{
    m_size = boundingRect().size().toSize();

    if (m_model) {
        m_model->setWallpaperSize(m_size);
    }
}

void MobileImage::paint(QPainter *painter, const QRectF& exposedRect)
{
    //this wallpaper doesn't actually paint
}

void MobileImage::setSingleImage()
{
    if (m_wallpaper.isEmpty()) {
        useSingleImageDefaults();
    }

    QString img;

    if (QDir::isAbsolutePath(m_wallpaper)) {
        Plasma::Package b(m_wallpaper, packageStructure(this));
        img = b.filePath("preferred");
        //kDebug() << img << m_wallpaper;

        if (img.isEmpty() && QFile::exists(m_wallpaper)) {
            img = m_wallpaper;
        }
    } else {
        //if it's not an absolute path, check if it's just a wallpaper name
        const QString path = KStandardDirs::locate("wallpaper", m_wallpaper + "/metadata.desktop");

        if (!path.isEmpty()) {
            QDir dir(path);
            dir.cdUp();

            Plasma::Package b(dir.path(), packageStructure(this));
            img = b.filePath("preferred");
        }
    }

    if (img.isEmpty()) {
        // ok, so the package we have failed to work out; let's try the default
        // if we have already
        const QString wallpaper = m_wallpaper;
        useSingleImageDefaults();
        if (wallpaper != m_wallpaper) {
            setSingleImage();
        }
    }

    kDebug() << "OOOOOOOOOOOOOOOOOOOOO" << img << m_wallpaper;
    m_wallpaperPath = img;
    emit wallpaperPathChanged();
}

void MobileImage::addUrls(const KUrl::List &urls)
{
    bool first = true;
    foreach (const KUrl &url, urls) {
        // set the first drop as the current paper, just add the rest to the roll
        addUrl(url, first);
        first = false;
    }
}

void MobileImage::addUrl(const KUrl &url, bool setAsCurrent)
{
    ///kDebug() << "droppage!" << url << url.isLocalFile();
    if (url.isLocalFile()) {
        const QString path = url.toLocalFile();
        setWallpaperName(path);
    } else {
        QString wallpaperName = KGlobal::dirs()->locateLocal("wallpaper", url.fileName());

        if (!wallpaperName.isEmpty()) {
            KIO::FileCopyJob *job = KIO::file_copy(url, KUrl(wallpaperName));
            if (setAsCurrent) {
                connect(job, SIGNAL(result(KJob*)), this, SLOT(setWallpaperRetrieved(KJob*)));
            } else {
                connect(job, SIGNAL(result(KJob*)), this, SLOT(addWallpaperRetrieved(KJob*)));
            }
        }
    }
}

void MobileImage::setWallpaperRetrieved(KJob *job)
{
    KIO::FileCopyJob *copyJob = qobject_cast<KIO::FileCopyJob *>(job);
    if (copyJob && !copyJob->error()) {
        setWallpaperName(copyJob->destUrl().toLocalFile());
    }
}

void MobileImage::addWallpaperRetrieved(KJob *job)
{
    KIO::FileCopyJob *copyJob = qobject_cast<KIO::FileCopyJob *>(job);
    if (copyJob && !copyJob->error()) {
        addUrl(copyJob->destUrl(), false);
    }
}

void MobileImage::setWallpaperName(const QString &path)
{
    if (m_wallpaper == path) {
        return;
    }
    m_wallpaper = path;
    setSingleImage();

    if (!m_usersWallpapers.contains(path)) {
        m_usersWallpapers.append(path);
    }
    emit wallpaperNameChanged();
}

QString MobileImage::wallpaperName() const
{
    return m_wallpaper;
}


QString MobileImage::wallpaperPath() const
{
    return m_wallpaperPath;
}


void MobileImage::getNewWallpaper()
{
    if (!m_newStuffDialog) {
        m_newStuffDialog = new KNS3::DownloadDialog( "wallpaper.knsrc", 0 );
        connect(m_newStuffDialog.data(), SIGNAL(accepted()), SLOT(newStuffFinished()));
    }
    m_newStuffDialog.data()->show();
}

void MobileImage::newStuffFinished()
{
    if (m_model && (!m_newStuffDialog || m_newStuffDialog.data()->changedEntries().size() > 0)) {
        m_model->reload();
    }
}

void MobileImage::pictureChanged(const QModelIndex &index)
{
    if (index.row() == -1 || !m_model) {
        return;
    }

    Plasma::Package *b = m_model->package(index.row());
    if (!b) {
        return;
    }

    if (b->structure()->contentsPrefixPaths().isEmpty()) {
        // it's not a full package, but a single paper
        m_wallpaper = b->filePath("preferred");
    } else {
        m_wallpaper = b->path();
    }

    setSingleImage();
}

void MobileImage::positioningChanged(int index)
{
    setSingleImage();

    setResizeMethodHint(m_resizeMethod);

    if (m_model) {
        m_model->setResizeMethod(m_resizeMethod);
    }
}


//FIXME: we have to save the configuration also when the dialog cancel button is clicked.
void MobileImage::removeWallpaper(QString name)
{
    int wallpaperIndex = m_usersWallpapers.indexOf(name);
    if (wallpaperIndex >= 0){
        m_usersWallpapers.removeAt(wallpaperIndex);
        m_model->reload(m_usersWallpapers);
        //TODO: save the configuration in the right way
        emit settingsChanged(true);
    }
}

#include "mobileimage.moc"
