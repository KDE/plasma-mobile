/*
 *   Copyright 2011 Marco Martin <notmart@gmail.com>
 *   Copyright 2010 Alexis Menard <menard@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License as published by
 *   the Free Software Foundation; either version 2 of the License, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details.
 *
 *   You should have received a copy of the GNU General Public License
 *   along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 */

#include "appletstatuswatcher.h"

#include <Plasma/Applet>

//TODO: move somewhere else?
AppletStatusWatcher::AppletStatusWatcher(QObject *parent)
    : QObject(parent)
{
}

AppletStatusWatcher::~AppletStatusWatcher()
{
}

void AppletStatusWatcher::setPlasmoid(QObject *plasmoid)
{
    Plasma::Applet *applet = qobject_cast<Plasma::Applet *>(plasmoid);
    if (!applet || m_plasmoid.data() == applet) {
        return;
    } else if (m_plasmoid) {
        disconnect(m_plasmoid.data(), 0, this, 0);
    }
    m_plasmoid = applet;
    connect(applet, SIGNAL(newStatus(Plasma::ItemStatus)), this, SIGNAL(statusChanged()));
}

QObject *AppletStatusWatcher::plasmoid() const
{
    return m_plasmoid.data();
}

void AppletStatusWatcher::setStatus(const AppletStatusWatcher::ItemStatus status)
{
    if (!m_plasmoid) {
        return;
    }

    m_plasmoid.data()->setStatus((Plasma::ItemStatus)status);
}

AppletStatusWatcher::ItemStatus AppletStatusWatcher::status() const
{
    if (!m_plasmoid) {
        return UnknownStatus;
    }

    return (AppletStatusWatcher::ItemStatus)((int)(m_plasmoid.data()->status()));
}

#include "appletstatuswatcher.moc"
