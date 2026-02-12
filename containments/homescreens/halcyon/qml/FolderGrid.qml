// SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import QtQuick.Effects
import QtQml.Models

import org.kde.plasma.components 3.0 as PC3
import org.kde.draganddrop as DragDrop

import org.kde.kirigami as Kirigami
import org.kde.plasma.private.mobileshell as MobileShell
import plasma.applet.org.kde.plasma.mobile.homescreen.halcyon as Halcyon

MobileShell.GridView {
    id: root
    property Halcyon.ApplicationFolder folder: null

    property string folderName: folder ? folder.name : ""
    property var folderModel: folder ? folder.applications : []

    required property bool twoColumn

    signal openConfigureRequested()
    signal closeRequested()

    property bool inFolderTitleEditMode: false

    TapHandler {
        onLongPressed: root.openConfigureRequested()
        onTapped: root.closeRequested()
    }

    header: MobileShell.BaseItem {
        topPadding: Math.round(root.height * 0.2)
        bottomPadding: Kirigami.Units.gridUnit
        leftPadding: 0
        rightPadding: 0
        implicitWidth: root.width

        background: Rectangle {
            color: 'transparent'
            TapHandler {
                onLongPressed: root.openConfigureRequested()
                onTapped: root.closeRequested()
            }
        }

        Component {
            id: folderTitleEdit

            TextEdit {
                text: root.folderName
                color: "white"
                selectByMouse: true
                wrapMode: TextEdit.Wrap

                Component.onCompleted: forceActiveFocus()

                font.weight: Font.Bold
                font.pointSize: 18

                layer.enabled: true
                layer.effect: MobileShell.TextDropShadow {}

                onTextChanged: {
                    if (text.includes('\n')) {
                        // exit text edit mode when new line is entered
                        root.inFolderTitleEditMode = false;
                    } else {
                        root.folder.name = text;
                    }
                }
                onEditingFinished: root.inFolderTitleEditMode = false
            }
        }

        Component {
            id: folderTitleLabel

            QQC2.Label {
                text: root.folderName
                color: "white"
                style: Text.Normal
                styleColor: "transparent"
                horizontalAlignment: Text.AlignLeft
                textFormat: Text.MarkdownText

                elide: Text.ElideRight
                wrapMode: Text.Wrap
                maximumLineCount: 2

                font.weight: Font.Bold
                font.pointSize: 18

                layer.enabled: true
                layer.effect: MobileShell.TextDropShadow {}

                MouseArea {
                    anchors.fill: parent
                    onClicked: root.inFolderTitleEditMode = true
                }
            }
        }

        contentItem: RowLayout {
            id: rowLayout
            spacing: Kirigami.Units.smallSpacing * 2

            // close folder button
            MouseArea {
                id: button
                Layout.alignment: Qt.AlignVCenter
                implicitHeight: Kirigami.Units.iconSizes.small + Kirigami.Units.gridUnit
                implicitWidth: Kirigami.Units.iconSizes.small + Kirigami.Units.gridUnit

                cursorShape: Qt.PointingHandCursor
                onClicked: root.closeRequested()

                // button background
                Rectangle {
                    anchors.fill: parent
                    color: Qt.rgba(255, 255, 255, button.pressed ? 0.2 : 0)
                    radius: button.width / 2
                }

                // button icon
                Kirigami.Icon {
                    anchors.centerIn: parent
                    implicitHeight: Kirigami.Units.iconSizes.small
                    implicitWidth: Kirigami.Units.iconSizes.small
                    isMask: true
                    color: 'white'
                    source: 'arrow-left'

                    layer.enabled: true
                    layer.effect: MultiEffect {
                        shadowEnabled: true
                        shadowVerticalOffset: 1
                        blurMax: 8
                        shadowOpacity: 0.6
                    }
                }
            }

            // folder title
            Loader {
                Layout.alignment: Qt.AlignVCenter
                Layout.fillWidth: true
                Layout.maximumWidth: rowLayout.width - button.width - rowLayout.spacing
                sourceComponent: root.inFolderTitleEditMode ? folderTitleEdit : folderTitleLabel
            }
        }
    }

    model: DelegateModel {
        id: visualModel
        model: root.folderModel

        delegate: Item {
            id: delegateRoot
            width: root.cellWidth
            height: root.cellHeight

            property int visualIndex: DelegateModel.itemsIndex

            DropArea {
                anchors.fill: parent
                onEntered: (drag) => {
                    let from = drag.source.visualIndex;
                    let to = appDelegate.visualIndex;
                    visualModel.items.move(from, to);
                    root.folder.moveEntry(from, to);
                }
            }

            FavoritesAppDelegate {
                id: appDelegate
                visualIndex: delegateRoot.visualIndex

                isFolder: false
                application: model.application

                menuActions: [
                    Kirigami.Action {
                        icon.name: "emblem-favorite"
                        text: i18n("Remove from favourites")
                        onTriggered: root.folder.removeApp(model.index)
                    },
                    Kirigami.Action {
                        icon.name: "document-open-folder"
                        text: i18n("Move out of folder")
                        onTriggered: root.folder.moveAppOut(model.index)
                    }
                ]

                implicitWidth: root.cellWidth
                implicitHeight: visible ? root.cellHeight : 0

                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter

                states: [
                    State {
                        when: appDelegate.drag.active
                        ParentChange {
                            target: appDelegate
                            parent: root
                        }

                        AnchorChanges {
                            target: appDelegate
                            anchors.horizontalCenter: undefined
                            anchors.verticalCenter: undefined
                        }
                    }
                ]
            }
        }
    }

    // animations
    displaced: Transition {
        NumberAnimation {
            properties: "x,y"
            easing.type: Easing.OutQuad
        }
    }
}
