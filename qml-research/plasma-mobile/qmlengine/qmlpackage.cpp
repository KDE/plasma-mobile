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

K_EXPORT_PLASMA_PACKAGESTRUCTURE(qmlpackage, QmlPackage)

QmlPackage::QmlPackage(QObject* parent, const QVariantList &args)
    :Plasma::PackageStructure(parent)
{
    Q_UNUSED(args);
    addDirectoryDefinition("qml", "qml/", i18n("Root folder for QML"));
    //qml doesn't have a mimetype yet?
    addFileDefinition("mainqml", "qml/main.qml", i18n("Main QML File"));
    setRequired("mainqml", true);
}

QmlPackage::~QmlPackage()
{
}
