/*
  Copyright (c) 2007 Paolo Capriotti <p.capriotti@gmail.com>
  Copyright (c) 2008 by Petri Damsten <damu@iki.fi>
  Copyright (c) 2011 Marco Martin <notmart@gmail.com>

  This program is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 2 of the License, or
  (at your option) any later version.
*/

#ifndef MOBILEIMAGE_H
#define MOBILEIMAGE_H

#include <QTimer>
#include <QPixmap>
#include <QStringList>
#include <QModelIndex>

#include <Plasma/Wallpaper>
#include <Plasma/Package>


class QPropertyAnimation;

class KDirWatch;
class KFileDialog;
class KJob;

namespace KNS3 {
    class DownloadDialog;
}

class BackgroundListModel;

class MobileImage : public Plasma::Wallpaper
{
    Q_OBJECT
    Q_PROPERTY(QString wallpaperName READ wallpaperName WRITE setWallpaperName)

    public:
        MobileImage(QObject* parent, const QVariantList& args);
        ~MobileImage();

        virtual void save(KConfigGroup &config);
        virtual void paint(QPainter* painter, const QRectF& exposedRect);

    public Q_SLOTS:
        void setWallpaperName(const QString &path);
        QString wallpaperName() const;

    signals:
        void settingsChanged(bool);

    protected slots:
        void removeWallpaper(QString name);
        void positioningChanged(int index);
        void getNewWallpaper();
        void pictureChanged(const QModelIndex &);

        void addUrl(const KUrl &url, bool setAsCurrent);
        void addUrls(const KUrl::List &urls);
        void setWallpaperRetrieved(KJob *job);
        void addWallpaperRetrieved(KJob *job);
        void newStuffFinished();

    protected:
        void init(const KConfigGroup &config);
        void calculateGeometry();
        void setSingleImage();
        void useSingleImageDefaults();

    private:

        Plasma::Wallpaper::ResizeMethod m_resizeMethod;
        QString m_wallpaper;
        QStringList m_usersWallpapers;

        QString m_mode;
        Plasma::Package *m_wallpaperPackage;
        BackgroundListModel *m_model;
        QSize m_size;
        QString m_img;
        QDateTime m_previousModified;
        QWeakPointer<KNS3::DownloadDialog> m_newStuffDialog;

        QAction* m_openImageAction;
};

#endif
