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

#include <QFile>
#include <QPainter>
#include <QTimer>

#include <KStandardDirs>

#include <Plasma/Containment>
#include <Plasma/Context>
#include <Plasma/DataContainer>
#include <Plasma/Wallpaper>

#include <Activities/Consumer>

#include "../cachingeffect.h"
//#include "dataenginetracker.h"

MobileActivityThumbnails::MobileActivityThumbnails(QObject *parent, const QVariantList &args)
    : Plasma::DataEngine(parent, args)
{
    m_consumer = new Activities::Consumer(this);
    m_saveTimer = new QTimer(this);
    m_saveTimer->setSingleShot(true);
    connect(m_saveTimer, SIGNAL(timeout()), this, SLOT(delayedSnapshotContainment()));
//    new DataEngineTracker(this);
}

bool MobileActivityThumbnails::sourceRequestEvent(const QString &source)
{
    if (!m_consumer->listActivities().contains(source)) {
        return false;
    }
    QString path = KStandardDirs::locateLocal("data", QString("plasma/activities-screenshots/%1.png").arg(source));

    if (QFile::exists(path)) {
        QImage image(path);
        DataEngine::Data data;
        data.insert("path", path);
        data.insert("image", image);
        setData(source, data);
    } else {
        setData(source, "path", QString());
    }

    // as we successfully set up the source, return true
    return true;
}

void MobileActivityThumbnails::snapshotContainment(Plasma::Containment *containment)
{
    if (!containment) {
        return;
    }

    if (containment->graphicsEffect()) {
        containment->graphicsEffect()->update();
    }

    m_containmentsToSave.append(containment);
    // FIXME: this is ugly. should be connected to the graphics effect being ready.
    m_saveTimer->start(1000);
}

void MobileActivityThumbnails::delayedSnapshotContainment()
{
    //FIXME: this really all ought to be a thread
    QSet<Plasma::Containment *> seen;
    foreach (QWeakPointer<Plasma::Containment> containment, m_containmentsToSave) {
        if (!containment || seen.contains(containment.data())) {
            continue;
        }

        seen.insert(containment.data());
        snapshot(containment.data());
    }

    m_containmentsToSave.clear();
}

void MobileActivityThumbnails::snapshot(Plasma::Containment *containment)
{
    if (!containment->wallpaper()) {
        return;
    }

    QImage activityImage = QImage(containment->size().toSize(), QImage::Format_ARGB32);
    const QString wallpaperPath = containment->wallpaper()->property("wallpaperPath").toString();
    QPainter p(&activityImage);
    //The wallpaper has paths or paints by itself?
    if (wallpaperPath.isEmpty()) {
        containment->wallpaper()->paint(&p, containment->wallpaper()->boundingRect());
    } else {
        //TODO: load a smaller image for this if available
        p.drawImage(QPoint(0,0), QImage(wallpaperPath));
    }
    p.setCompositionMode(QPainter::CompositionMode_SourceOver);

    CachingEffect *cache = qobject_cast<CachingEffect *>(containment->graphicsEffect());
    if (cache) {
        p.drawPixmap(QPoint(0,0), cache->cachedPixmap());
    }

    p.end();

    const QString activity = containment->context()->currentActivityId();
    const QString path = KStandardDirs::locateLocal("data", QString("plasma/activities-screenshots/%1.png").arg(activity));
    activityImage.save(path, "PNG");
    Plasma::DataContainer *container = containerForSource(activity);
    //kDebug() << "setting the thumbnail for" << activity << path << container;
    if (container) {
        container->setData("path", path);
        container->setData("image", activityImage);
        scheduleSourcesUpdated();
    }
}

K_EXPORT_PLASMA_DATAENGINE(org.kde.mobileactivitythumbnails, MobileActivityThumbnails)


#include "mobileactivitythumbnails.moc"

