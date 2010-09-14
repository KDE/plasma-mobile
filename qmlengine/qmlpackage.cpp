/*
 *   Copyright 2009 by Alan Alpert <alan.alpert@nokia.com>
 *   Copyright 2010 by Ménard Alexis <menard@kde.org>

 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2, or
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

#include "qmlpackage.h"

#include <KDesktopFile>
#include <KConfigGroup>

K_EXPORT_PLASMA_PACKAGESTRUCTURE(qmlscripts, QmlPackage)

QmlPackage::QmlPackage(QObject* parent, const QVariantList &args)
    :Plasma::PackageStructure(parent)
{
    Q_UNUSED(args);
    addDirectoryDefinition("qml", "qml/", i18n("Root folder for QML"));
    //qml doesn't have a mimetype yet?
    addFileDefinition("mainqml", "qml/main.qml", i18n("Main QML File"));
    setRequired("mainqml", true);
    addFileDefinition("mainscript", "qml/main.qml", i18n("Main QML File"));
    setRequired("mainscript", true);

    addDirectoryDefinition("images", "images/", i18n("Images"));
    QStringList mimetypes;
    mimetypes << "image/svg+xml" << "image/png" << "image/jpeg";
    setMimetypes("images", mimetypes);

    addDirectoryDefinition("config", "config/", i18n("Configuration Definitions"));
    mimetypes.clear();
    mimetypes << "text/xml";
    setMimetypes("config", mimetypes);
    addFileDefinition("mainconfigxml", "config/main.xml", i18n("Main Script File"));

    addDirectoryDefinition("ui", "ui", i18n("User Interface"));
    setMimetypes("ui", mimetypes);

    addDirectoryDefinition("data", "data", i18n("Data Files"));

    addDirectoryDefinition("translations", "locale", i18n("Translations"));
}

QmlPackage::~QmlPackage()
{
}

void QmlPackage::pathChanged()
{
    KDesktopFile config(path() + "/metadata.desktop");
    KConfigGroup cg = config.desktopGroup();
    QString mainScript = cg.readEntry("X-Plasma-MainScript", QString());
    if (!mainScript.isEmpty()) {
        addFileDefinition("mainscript", mainScript, i18n("Main QML File"));
        addFileDefinition("mainqml", mainScript, i18n("Main QML File"));
    }
}
