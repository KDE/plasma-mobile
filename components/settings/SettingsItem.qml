// -*- coding: iso-8859-1 -*-
/*
 *   Copyright 2011-2012 Sebastian Kügler <sebas@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2 or
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

import QtQuick 1.0
import org.kde.plasma.components 0.1 as PlasmaComponents
import org.kde.plasma.mobilecomponents 0.1 as MobileComponents
import org.kde.active.settings 0.1 as ActiveSettings

PlasmaComponents.PageStack {

    property alias module: settingsComponent.module

    id: moduleContainer
    objectName: "moduleContainer"
    clip: true

    ActiveSettings.SettingsComponent {
        id: settingsComponent

        onModuleChanged: {
            if (module != "") {
                switcherPackage.name = module
                print(" Loading package: " + switcherPackage.filePath("mainscript"));
                moduleContainer.replace(switcherPackage.filePath("mainscript"));
            }
        }
    }

    MobileComponents.Package {
        id: switcherPackage
    }
}
