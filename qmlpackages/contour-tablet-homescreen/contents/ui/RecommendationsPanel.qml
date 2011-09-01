/***************************************************************************
 *   Copyright 2010 Alexis Menard <menard@kde.org>                         *
 *   Copyright 2010 Artur Duque de Souza <asouza@kde.org>                  *
 *   Copyright 2010 Marco Martin <mart@kde.org>                            *
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
 ***************************************************************************/

import QtQuick 1.0
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.mobilecomponents 0.1
import org.kde.plasma.mobilecomponents 0.1 as MobileComponents

Item {
    id: recommendationsPanel
    height: parent.height/1.2
    width: parent.width/1.8
    state: "hidden"
    property Item recommendations
    enabled: recommendations.state == "Passive"?false:true
    onEnabledChanged: {
        if (!enabled) {
            state = "disabled"
        } else if (state == "disabled") {
            state = "hidden"
        }
    }

    MobileComponents.Package {
        id: recommendationsPackage
        name: "org.kde.contour.recommendations"
        Component.onCompleted: {
            var component = Qt.createComponent(recommendationsPackage.filePath("mainscript"));
            recommendationsPanel.recommendations = component.createObject(mainFrame);
            recommendationsPanel.recommendations.anchors.fill = mainFrame
            recommendationsPanel.recommendations.anchors.topMargin = titleItem.height+mainFrame.margins.top
            recommendationsPanel.recommendations.anchors.rightMargin = mainFrame.margins.right
        }
    }

    MouseEventListener {
        id: hintregion;

        anchors.fill: parent
        anchors.rightMargin: -60
        enabled: recommendations.state == "Passive"?false:true

        property int startX
        property int startMouseX
        property string previousState
        onPressed: {
            startMouseX = mouse.screenX
            startX = recommendationsPanel.x
            hideTimer.running = false
            previousState = recommendationsPanel.state
            recommendationsPanel.state = "dragging"
        }

        onPositionChanged: {
            recommendationsPanel.x = Math.min(startX + (mouse.screenX - startMouseX), 0)

            hideTimer.running = false
        }

        onReleased: {
            if ((previousState == "show" && recommendationsPanel.x > -recommendationsPanel.width/3) ||
                (previousState == "hidden" && recommendationsPanel.x > -recommendationsPanel.width/3*2)) {
                recommendationsPanel.state = "show"
                hideTimer.restart()
            } else {
                recommendationsPanel.state = "hidden"
            }
        }

        PlasmaCore.FrameSvgItem {
            id: hint
            anchors.left: mainFrame.right
            anchors.leftMargin: -8
            width: 48
            height: 80
            anchors.verticalCenter: parent.verticalCenter
            imagePath: "widgets/background"
            enabledBorders: "RightBorder|TopBorder|BottomBorder"

            PlasmaCore.SvgItem {
                id: arrowSvgItem
                width:32
                height:32
                svg: PlasmaCore.Svg {
                    imagePath: homeScreenPackage.filePath("images", "panel-icons.svgz")
                }

                elementId: "contour"
                anchors {
                    verticalCenter: parent.verticalCenter
                    right: hint.right
                    rightMargin: hint.margins.right -5
                }
            }

            Behavior on opacity {
                NumberAnimation {duration: 1000}
            }
            MouseArea {
                anchors.fill: parent
                property int startX
                onPressed: startX = recommendationsPanel.x
                onClicked: {
                    if (Math.abs(startX - recommendationsPanel.x) < 8) {
                        recommendationsPanel.state = recommendationsPanel.x == 0?"hidden":"show"
                    }
                }
            }
        }

        PlasmaCore.FrameSvgItem {
            id: mainFrame
            width: parent.width-60
            height: parent.height-80
            y: 80
            imagePath: "dialogs/background"
            enabledBorders: "RightBorder|TopBorder"
            PlasmaCore.FrameSvgItem {
                id: titleItem
                imagePath: "widgets/extender-dragger"
                prefix: "root"
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    leftMargin: parent.margins.left
                    rightMargin: parent.margins.right
                    topMargin: parent.margins.top
                }
                height: titleText.height + margins.top + margins.bottom
                Text {
                    id: titleText
                    text: i18n("Recommendations")
                    font.pixelSize: 18
                    anchors {
                        top: parent.top
                        horizontalCenter: parent.horizontalCenter
                        topMargin: parent.margins.top
                    }
                }
            }
        }
    }

    Timer {
        id : hideTimer
        interval: 4000;
        running: false;
        onTriggered:  {
            recommendationsPanel.state = "hidden"
        }
    }

    MouseArea {
        id: hideTimerResetRegion;
        z: 9000

        anchors.fill: parent

        onPressed: {
            hideTimer.restart()
            mouse.accepted = false
        }
    }

    states: [
        State {
            name: "show";
            PropertyChanges {
                target: recommendationsPanel;
                x: 0;
            }
            PropertyChanges {
                target: hideTimer;
                running: true
            }
        },
        State {
            name: "hidden";
            PropertyChanges {
                target: recommendationsPanel;
                x: - width;
            }
        },
        State {
            name: "disabled";
            PropertyChanges {
                target: recommendationsPanel;
                x: - width - 60;
            }
        },
        State {
            name: "dragging"
            PropertyChanges {
                target: recommendationsPanel
                x: recommendationsPanel.x
            }
        }
    ]

    transitions: [
        Transition {
            from: "show";
            to: "hidden";
            NumberAnimation {
                properties: "x";
                easing.type: "InOutCubic";
                duration: 500;
            }
        },
        Transition {
            from: "hidden";
            to: "show";
            NumberAnimation {
                properties: "x";
                easing.type: "InOutCubic";
                duration: 400;
            }
        },
        Transition {
            from: "dragging";
            to: "*";
            NumberAnimation {
                properties: "x";
                easing.type: "OutQuad";
                duration: 400;
            }
        }
    ]

}
