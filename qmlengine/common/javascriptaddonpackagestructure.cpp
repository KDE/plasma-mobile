/*
 *   Copyright 2010 Aaron J. Seigo <aseigo@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License version 2 as
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

#include "javascriptaddonpackagestructure.h"

#include <KConfigGroup>
#include <KDesktopFile>

JavascriptAddonPackageStructure::JavascriptAddonPackageStructure(QObject *parent, const QVariantList &args)
    : Plasma::PackageStructure(parent, "Plasma/JavascriptAddon")
{
    Q_UNUSED(args)
    setServicePrefix("plasma-javascriptaddon-");
    setDefaultPackageRoot("plasma/javascript-addons/");
    addDirectoryDefinition("images", "images/", i18n("Images"));
    QStringList mimetypes;
    mimetypes << "image/svg+xml" << "image/png" << "image/jpeg";
    setMimetypes("images", mimetypes);

    addDirectoryDefinition("config", "config/", i18n("Configuration Definitions"));
    mimetypes.clear();
    mimetypes << "text/xml";
    setMimetypes("config", mimetypes);

    addDirectoryDefinition("ui", "ui", i18n("User Interface"));
    setMimetypes("ui", mimetypes);

    addDirectoryDefinition("data", "data", i18n("Data Files"));

    addDirectoryDefinition("scripts", "code", i18n("Executable Scripts"));
    mimetypes.clear();
    mimetypes << "text/plain";
    setMimetypes("scripts", mimetypes);

    addDirectoryDefinition("translations", "locale", i18n("Translations"));

    addDirectoryDefinition("animations", "animations/", i18n("Animation scripts"));

    addFileDefinition("mainscript", "code/main.js", i18n("Main Script File"));
    setRequired("mainscript", true);
}

void JavascriptAddonPackageStructure::pathChanged()
{
    KDesktopFile config(path() + "/metadata.desktop");
    KConfigGroup cg = config.desktopGroup();
    QString mainScript = cg.readEntry("X-Plasma-MainScript", QString());
    if (!mainScript.isEmpty()) {
        addFileDefinition("mainscript", mainScript, i18n("Main Script File"));
    }
}

#include "javascriptaddonpackagestructure.moc"

