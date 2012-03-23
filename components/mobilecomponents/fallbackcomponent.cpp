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
    foreach (const QString &path, paths) {
        //kDebug() << "Searching for" << path;
        //TODO: cache this, to prevent too much disk access
        QString resolved = KStandardDirs::locate("data", "plasma/" + component + '/' + path);
        if (!resolved.isEmpty()) {
            return resolved;
        }
    }
    return QString();
}

#include "fallbackcomponent.moc"
