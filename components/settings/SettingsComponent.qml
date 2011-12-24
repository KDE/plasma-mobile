// -*- coding: iso-8859-1 -*-
/*
 *   Copyright 2011 Sebastian Kügler <mart@kde.org>
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
//import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.mobilecomponents 0.1 as MobileComponents
//import org.kde.plasma.components 0.1 as PlasmaComponents

Column {

    Text {
        text: "<h1>yeah.</h1>"
        anchors.fill: parent
    }

    MobileComponents.Package {
        width: 500
        height: 500
        id: switcherPackage
    }

    function loadPackage(module) {
        // Load the C++ plugin into our context
        //settingsRoot.loadPlugin(module);
        switcherPackage.name = module
        print(" Loading package: " + switcherPackage.filePath("mainscript"));
        //moduleContainer.replace(switcherPackage.filePath("mainscript"));
    }

    Component.onCompleted: {
        if (typeof(startModule) != "undefined") {
            print("Startmodule :: " + startModule);
            loadPackage(startModule);
        } else {
            print("Startmodule undefined.");
        }
    }
}