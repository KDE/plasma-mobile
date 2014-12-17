/***************************************************************************
 *                                                                         *
 *   Copyright 2014 Sebastian Kügler <sebas@kde.org>                       *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA .        *
 *                                                                         *
 ***************************************************************************/

import QtQuick 2.3
//import QtQuick.Controls 1.0

//import QtWebEngine 1.0

import QtQuick.Layouts 1.0

import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras


Item {

    id: tabsRoot

    Rectangle { anchors.fill: parent; color: "brown"; opacity: 0.5; }

    ShaderEffectSource {
        id: shaderItem

        //hideSource: contentView.state == "tabs"
        live: false
        //width: 100; height: 100
        anchors.centerIn: parent
        width: tabsRoot.width / 2
        height: Math.round(width * 0.666)

        sourceItem: currentWebView

        Behavior on height {
            SequentialAnimation {
                ScriptAction {
                    script: {
                        print("ANimation start");
                        // switch to tabs
                    }
                }
                NumberAnimation { duration: units.longDuration; easing.type: Easing.InOutQuad }
                NumberAnimation { duration: units.shortDuration; easing.type: Easing.InOutQuad; target: contentView; property: opacity }
                ScriptAction {
                    script: {
                        print("ANimation done");
                        contentView.state = "hidden"
                    }
                }
            }
        }

        Behavior on width {
            NumberAnimation { duration: units.longDuration; easing.type: Easing.InOutQuad}

        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                print("Switch to tab");
                if (shaderItem.width < tabsRoot.width) {
                    shaderItem.width = tabsRoot.width
                    shaderItem.height = tabsRoot.height
                } else {
                    shaderItem.width = tabsRoot.width / 3
                    shaderItem.height = shaderItem.width * 0.666
                }
            }

        }
    }

}
