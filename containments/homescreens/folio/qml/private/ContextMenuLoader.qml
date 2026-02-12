// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick
import QtQuick.Window
import QtQuick.Layouts

import org.kde.plasma.components 3.0 as PC3
import org.kde.kirigami 2.10 as Kirigami

Loader {
    id: root
    active: false

    property list<Kirigami.Action> actions

    function open() {
        root.active = true;
        root.item.open();
    }

    function close() {
        if (root.item) {
            root.item.close();
        }
    }

    sourceComponent: PC3.Menu {
        id: menu
        title: "Context Menu"
        closePolicy: PC3.Menu.CloseOnReleaseOutside | PC3.Menu.CloseOnEscape

        Repeater {
            model: root.actions
            delegate: PC3.MenuItem {
                icon.name: modelData.iconName
                text: modelData.text
                enabled: modelData.enabled
                onClicked: modelData.triggered()
            }
        }

        onClosed: root.active = false
    }
}
