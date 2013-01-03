/*
 *   Copyright 2006 Aaron Seigo <aseigo@kde.org>
 *   Copyright 2012 Marco Martin <mart@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License version 2 
 *   published by the Free Software Foundation
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

#include <KComponentData>
#include <KConfig>
#include <KConfigGroup>
#include <KStandardDirs>

#include <KDebug>
int main()
{
    KComponentData cd("activenotifications-to-orgkdenotifications-update");
    QString file = KStandardDirs::locateLocal("config", "plasma-device-appletsrc");

    if (file.isEmpty()) {
        return 0;
    }

    KConfig config(file);
    KConfigGroup containments(&config, "Containments");
    foreach (const QString &group, containments.groupList()) {
        KConfigGroup applets(&containments, group);
        applets = KConfigGroup(&applets, "Applets");
        foreach (const QString &appletGroup, applets.groupList()) {
            KConfigGroup applet(&applets, appletGroup);
            QString plugin = applet.readEntry("plugin", QString());
            if (plugin == "org.kde.active.notifications") {
                applet.writeEntry("plugin", "org.kde.notifications");
            }
        }
    }

    return 0;
}

