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
#include "../kactivityconsumer.h"

#include <QFile>

#include <KStandardDirs>

MobileActivityThumbnails::MobileActivityThumbnails(QObject *parent, const QVariantList &args)
    : Plasma::DataEngine(parent, args)
{
    m_consumer = new KActivityConsumer(this);
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

K_EXPORT_PLASMA_DATAENGINE(org.kde.mobileactivitythumbnails, MobileActivityThumbnails)


#include "mobileactivitythumbnails.moc"

