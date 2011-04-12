/*
 *   Copyright 2011 Marco Martin <mart@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2 or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#include "mobileactivitythumbnails.h"
#include "../cachingeffect.h"
#include "../kactivityconsumer.h"

#include <QFile>
#include <QPainter>
#include <QTimer>

#include <KStandardDirs>

#include <Plasma/Containment>
#include <Plasma/Context>
#include <Plasma/Wallpaper>

MobileActivityThumbnails::MobileActivityThumbnails(QObject *parent, const QVariantList &args)
    : Plasma::DataEngine(parent, args)
{
    m_consumer = new KActivityConsumer(this);
    m_saveTimer = new QTimer(this);
    m_saveTimer->setSingleShot(true);
    connect(m_saveTimer, SIGNAL(timeout()), this, SLOT(delayedSnapshotContainment()));
}

bool MobileActivityThumbnails::sourceRequestEvent(const QString &source)
{
    if (!m_consumer->listActivities().contains(source)) {
        return false;
    }
    QString path = KStandardDirs::locateLocal("data", QString("plasma/activities-screenshots/%1.png").arg(source));

    if (QFile::exists(path)) {
        setData(source, "path", path);
    } else {
        setData(source, "path", QString());
    }

    // as we successfully set up the source, return true
    return true;
}

bool MobileActivityThumbnails::updateSourceEvent(const QString &source)
{
    QString path = KStandardDirs::locateLocal("data", QString("plasma/activities-screenshots/%1.png").arg(source));

    if (QFile::exists(path)) {
        setData(source, "path", path);
    } else {
        setData(source, "path", QString());
    }

    return true;
}

void MobileActivityThumbnails::snapshotContainment(Plasma::Containment *cont)
{
    m_containmentToSave = cont;
    m_containmentToSave.data()->graphicsEffect()->update();
    m_saveTimer->start(1000);
}

void MobileActivityThumbnails::delayedSnapshotContainment()
{
    QGraphicsEffect *effect = m_containmentToSave.data()->graphicsEffect();
    //FIXME: is this REALLY sure?
    CachingEffect *cache = static_cast<CachingEffect *>(effect);

    QImage activityImage = QImage(m_containmentToSave.data()->size().toSize(), QImage::Format_ARGB32);

    QString wallpaperPath = m_containmentToSave.data()->wallpaper()->property("wallpaperPath").toString();
    QPainter p(&activityImage);
    //The wallpaper has paths or paints by itself?
    if (wallpaperPath.isEmpty()) {
        m_containmentToSave.data()->wallpaper()->paint(&p, m_containmentToSave.data()->wallpaper()->boundingRect());
    } else {
        //TODO: load a smaller image for this if available
        p.drawImage(QPoint(0,0), QImage(wallpaperPath));
    }
    p.setCompositionMode(QPainter::CompositionMode_SourceOver);
    p.drawPixmap(QPoint(0,0), cache->cachedPixmap());
    p.end();

    QString path = KStandardDirs::locateLocal("data", QString("plasma/activities-screenshots/%1.png").arg(m_containmentToSave.data()->context()->currentActivityId()));

    activityImage.save(path, "PNG");
}

K_EXPORT_PLASMA_DATAENGINE(org.kde.mobileactivitythumbnails, MobileActivityThumbnails)


#include "mobileactivitythumbnails.moc"

