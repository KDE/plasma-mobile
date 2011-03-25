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
    Q_PROPERTY(QString wallpaperPath READ wallpaperPath WRITE setWallpaperPath)

    public:
        MobileImage(QObject* parent, const QVariantList& args);
        ~MobileImage();

        virtual void save(KConfigGroup &config);
        virtual void paint(QPainter* painter, const QRectF& exposedRect);

    public Q_SLOTS:
        void setWallpaperPath(const QString &path);
        QString wallpaperPath() const;

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
        void imageFileAltered(const QString &path);

    protected:
        void init(const KConfigGroup &config);
        void suspendStartup(bool suspend); // for ksmserver
        void calculateGeometry();
        void setSingleImage();
        void updateWallpaperActions();
        void useSingleMobileImageDefaults();

    private:
        static bool s_startupResumed;
        static bool s_startupSuspended;

        Plasma::Wallpaper::ResizeMethod m_resizeMethod;
        QStringList m_dirs;
        QString m_wallpaper;
        QStringList m_usersWallpapers;
        KDirWatch *m_fileWatch;

        QString m_mode;
        Plasma::Package *m_wallpaperPackage;
        QTimer m_timer;
        QPixmap m_pixmap;
        QPixmap m_oldPixmap;
        QPixmap m_oldFadedPixmap;
        BackgroundListModel *m_model;
        QSize m_size;
        QString m_img;
        QDateTime m_previousModified;
        QWeakPointer<KNS3::DownloadDialog> m_newStuffDialog;
        QString m_findToken;

        QAction* m_openImageAction;
};

#endif
