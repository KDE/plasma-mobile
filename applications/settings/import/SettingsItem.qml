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

import QtQuick 2.2
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.mobilecomponents 0.2 as MobileComponents
import org.kde.active.settings 2.0 as ActiveSettings

PlasmaComponents.PageStack {
    id: moduleContainer
    objectName: "moduleContainer"

    property alias module: settingsComponent.module
    property alias icon: settingsComponent.icon

    signal moduleLoaded

    function pushModule(module) {
        switcherPackage.name = module
        var mainscript = switcherPackage.filePath("mainscript");
        //print("Loading mainscript: " + mainscript);
        settingsLoader.source = mainscript;
        moduleContainer.push(settingsLoader);
        moduleContainer.module = module
    }

    clip: true

    Loader {
        id: settingsLoader
        anchors.fill: parent
    }

    ActiveSettings.SettingsComponent {
        id: settingsComponent

        onModuleChanged: {
            if (module == "") {
                moduleContainer.pop();
            } else if (switcherPackage.name != module) {
                switcherPackage.name = module
                //print(" Loading package: " + switcherPackage.filePath("mainscript") + " " + module);
                var mainscript = switcherPackage.filePath("mainscript");
                settingsLoader.source = switcherPackage.filePath("mainscript");
                //moduleContainer.replace(switcherPackage.filePath("mainscript"));
                print("Loaded mainscript: " + mainscript);
                moduleLoaded();
            }
        }
    }

    MobileComponents.Package {
        id: switcherPackage
    }
}
