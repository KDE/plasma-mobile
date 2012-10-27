/*
 *   Copyright 2011 Marco Martin <mart@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU Library General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#include "fallbackcomponent.h"


#include <QFile>


#include <KStandardDirs>
#include <KDebug>


FallbackComponent::FallbackComponent(QObject *parent)
    : QObject(parent)
{
}

QString FallbackComponent::resolvePath(const QString &component, const QStringList &paths)
{
    QString resolved;
    foreach (const QString &path, paths) {
        //kDebug() << "Searching for" << path;
        const QString key = component + '/' + path;
        if (m_paths.contains(key)) {
            resolved = *m_paths.object(key);
            if (!resolved.isEmpty()) {
                break;
            } else {
                continue;
            }
        }

        resolved = KStandardDirs::locate("data", "plasma/" + key);
        m_paths.insert(key, new QString(resolved));
        if (!resolved.isEmpty()) {
            break;
        }
    }

    return resolved;
}

#include "fallbackcomponent.moc"
