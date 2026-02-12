// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import QtQuick.Controls as QQC2

import org.kde.kirigami 2.20 as Kirigami

import org.kde.plasma.private.mobileshell as MobileShell
import plasma.applet.org.kde.plasma.mobile.homescreen.folio as Folio

MobileShell.BaseItem {
    id: root
    property Folio.HomeScreen folio

    property Folio.FolioApplicationFolder folder
    property bool inFolderTitleEditMode: false

    Connections {
        target: folio.HomeScreenState

        function onLeftCurrentFolder() {
            root.inFolderTitleEditMode = false;
        }
    }

    background: Rectangle {
        color: 'transparent'
        TapHandler {
            onTapped: {
                root.close()
            }
        }
    }

    Component {
        id: folderTitleEdit

        TextEdit {
            text: root.folder ? root.folder.name : ""
            color: "white"
            selectByMouse: true
            wrapMode: TextEdit.Wrap
            horizontalAlignment: TextEdit.AlignHCenter

            Component.onCompleted: {
                forceActiveFocus();
                cursorPosition = text.length;
            }

            font.weight: Font.Bold
            font.pointSize: 18

            layer.enabled: true
            layer.effect: MobileShell.TextDropShadow {}

            onTextChanged: {
                if (text.includes('\n')) {
                    // exit text edit mode when new line is entered
                    root.inFolderTitleEditMode = false;
                } else if (root.folder) {
                    root.folder.name = text;
                }
            }
            onEditingFinished: root.inFolderTitleEditMode = false
        }
    }

    Component {
        id: folderTitleLabel

        QQC2.Label {
            text: root.folder ? root.folder.name : ""
            color: "white"
            style: Text.Normal
            styleColor: "transparent"
            horizontalAlignment: Text.AlignHCenter
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

    // folder title
    contentItem: Loader {
        Layout.alignment: Qt.AlignVCenter
        Layout.fillWidth: true
        sourceComponent: root.inFolderTitleEditMode ? folderTitleEdit : folderTitleLabel
    }
}
