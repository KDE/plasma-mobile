/*
 *   Copycontext 2015 Marco Martin <mart@kde.org>
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

import QtQuick 2.1
import QtQuick.Layouts 1.3
import QtQuick.Controls 1.3
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.mobilecomponents 0.2 as MobileComponents
import org.kde.kquickcontrolsaddons 2.0


ToolBar {
    id: root
    property var actions
    property alias toolbarDelegate: internalButtons.data
    property Item configureButton: configureButton
    property Item menuButton: menuButton

    RowLayout {
        anchors.fill: parent
        //TODO: those buttons should support drag to open the menus as well
        PlasmaComponents.ToolButton {
            id: configureButton
            iconSource: "configure"
            checkable: true
            onCheckedChanged: {
                globalDrawerOpen = checked
                if (checked) {
                    contextDrawerOpen = false;
                }
            }
        }
        Item {
            Layout.fillWidth: true
        }
        RowLayout {
            id: internalButtons
            Layout.fillWidth: false
            Repeater {
                model: {
                    if (root.actions.length == 0) {
                        return null;
                    } else {
                        return root.actions[0].text !== undefined &&
                            root.actions[0].trigger !== undefined ?
                                root.actions :
                                root.actions[0];
                    }
                }
                delegate: PlasmaComponents.ToolButton {
                    iconSource: modelData.iconName
                    onClicked: {
                        if (modelData && modelData.trigger !== undefined) {
                            modelData.trigger();
                        // assume the model is a list of QAction or Action
                        } else if (toolbar.model.length > index) {
                            toolbar.model[index].trigger();
                        } else {
                            console.log("Don't know how to trigger the action")
                        }
                    }
                }
            }
            onChildrenChanged: {
                var flexibleFound = false;
                for (var i = 0; i < children.length; ++i) {
                    if (children[i].Layout.fillWidth) {
                        flexibleFound = true;
                        break;
                    }
                }
                Layout.fillWidth = flexibleFound;
            }
        }
        Item {
            Layout.fillWidth: true
        }
        PlasmaComponents.ToolButton {
            id: menuButton
            iconSource: "applications-other"
            checkable: true
            onCheckedChanged: {
                contextDrawerOpen = checked
                if (checked) {
                    globalDrawerOpen = false;
                }
            }
        }
    }
}
