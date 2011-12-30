// -*- coding: iso-8859-1 -*-
/*
 *   Copyright 2011 Sebastian Kügler <sebas@kde.org>
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
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.mobilecomponents 0.1 as MobileComponents
import org.kde.active.settings 0.1 as ActiveSettings
import org.kde.plasma.components 0.1 as PlasmaComponents

Item {

    property alias module: settingsComponent.module
    property alias initialPage: moduleContainer.initialPage
    
    PlasmaComponents.PageStack {
        id: moduleContainer
        objectName: "moduleContainer"
        clip: false
        //initialPage: initial_page
        anchors.fill: parent
    }

    states: [
        State {
            id: expanded
            name: "expanded";
            PropertyChanges {
                target: settingsRoot
                opacity: 1
            }
        },

        State {
            id: collapsed
            name: "collapsed";
            PropertyChanges {
                target: settingsRoot
                opacity: 0
            }
        }
    ]

    transitions: [
        Transition {
            PropertyAnimation {
                properties: "opacity"
                duration: 400;
                easing.type: Easing.InOutElastic;
                easing.amplitude: 2.0; easing.period: 1.5
            }
        }
    ]

    ActiveSettings.SettingsComponent {
        id: settingsComponent

        onModuleChanged: {
            //print("mainscriptChanged:: " + mainScript);
            //moduleContainer.replace(mainScript);
            switcherPackage.name = module
            print(" Loading package: " + switcherPackage.filePath("mainscript"));
            moduleContainer.replace(switcherPackage.filePath("mainscript"));
        }
    }

    MobileComponents.Package {
        id: switcherPackage
    }
}