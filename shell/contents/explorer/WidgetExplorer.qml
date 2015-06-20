/*
 *   Copyright 2011 Marco Martin <mart@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2 or
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

import QtQuick 2.2
import QtQuick.Controls 1.1

import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.kquickcontrolsaddons 2.0

import QtQuick.Window 2.1
import QtQuick.Layouts 1.1

import org.kde.plasma.private.shell 2.0

PlasmaCore.FrameSvgItem {
    id: main
    imagePath: "widgets/background"
    enabledBorders: PlasmaCore.FrameSvgItem.RightBorder

    width: Math.max(heading.paintedWidth, units.gridUnit * 16)
    height: 800//Screen.height

    property alias containment: widgetExplorer.containment

    //external drop events can cause a raise event causing us to lose focus and
    //therefore get deleted whilst we are still in a drag exec()
    //this is a clue to the owning dialog that hideOnWindowDeactivate should be deleted
    //See https://bugs.kde.org/show_bug.cgi?id=332733
    property bool preventWindowHide: false

    property Item getWidgetsButton
    property Item categoryButton

    signal closed()

    function addCurrentApplet() {
        var pluginName = list.currentItem ? list.currentItem.pluginName : ""
        if (pluginName) {
            widgetExplorer.addApplet(pluginName)
        }
    }


    WidgetExplorer {
        id: widgetExplorer
        //view: desktop
        onShouldClose: main.closed();
    }

    GridLayout {
        id: topBar
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            topMargin: 0
            leftMargin: units.smallSpacing
            rightMargin: main.margins.right
        }
        columns: 2

        PlasmaExtras.Title {
            id: heading
            text: i18nd("plasma_shell_org.kde.plasma.desktop", "Widgets")
            Layout.fillWidth: true
        }

        PlasmaComponents.ToolButton {
            id: closeButton
            anchors {
                right: parent.right
                verticalCenter: heading.verticalCenter
            }
            iconSource: "window-close"
            onClicked: main.closed()
        }

        PlasmaComponents.TextField {
            id: searchInput
            clearButtonShown: true
            placeholderText: i18nd("plasma_shell_org.kde.plasma.desktop", "Search...")
            onTextChanged: {
                list.positionViewAtBeginning()
                list.currentIndex = -1
                widgetExplorer.widgetsModel.searchTerm = text
            }

            Component.onCompleted: forceActiveFocus()
            Layout.columnSpan: 2
            Layout.fillWidth: true
        }
    }

    PlasmaCore.FrameSvgItem {
        id: backgroundHint
        imagePath: "widgets/viewitem"
        prefix: "normal"
        visible: false
    }
    PlasmaExtras.ScrollArea {
        anchors {
            top: topBar.bottom
            left: parent.left
            right: parent.right
            bottom: bottomBar.top
            topMargin: units.smallSpacing
            leftMargin: units.smallSpacing
            bottomMargin: units.smallSpacing
            rightMargin: main.margins.right
        }
        ListView {
            id: list

            model: widgetExplorer.widgetsModel
            activeFocusOnTab: true
            currentIndex: -1
            keyNavigationWraps: true

            delegate: AppletDelegate {}

            //slide in to view from the left
            add: Transition {
                NumberAnimation {
                    properties: "x"
                    from: -list.width
                    to: 0
                    duration: units.shortDuration * 3

                }
            }

            //slide out of view to the right
            remove: Transition {
                NumberAnimation {
                    properties: "x"
                    to: list.width
                    duration: units.shortDuration * 3
                }
            }

            //if we are adding other items into the view use the same animation as normal adding
            //this makes everything slide in together
            //if we make it move everything ends up weird
            addDisplaced: list.add

            //moved due to filtering
            displaced: Transition {
                NumberAnimation {
                    properties: "y"
                    duration: units.shortDuration * 3
                }
            }
        }
    }

    Column {
        id: bottomBar
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            leftMargin: units.smallSpacing
            rightMargin: units.smallSpacing
            bottomMargin: units.smallSpacing
        }

        spacing: units.smallSpacing

        Repeater {
            model: widgetExplorer.extraActions.length
            PlasmaComponents.Button {
                anchors {
                    left: parent.left
                    right: parent.right
                }
                iconSource: widgetExplorer.extraActions[modelData].icon
                text: widgetExplorer.extraActions[modelData].text
                onClicked: {
                    widgetExplorer.extraActions[modelData].trigger()
                }
            }
        }
    }

    Component.onCompleted: {
        main.getWidgetsButton = getWidgetsButton
        main.categoryButton = categoryButton
    }
}

