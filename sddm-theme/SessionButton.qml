/*
    SPDX-FileCopyrightText: 2016 David Edmundson <davidedmundson@kde.org>
    SPDX-FileCopyrightText: 2022 Aleix Pol Gonzalez <aleixpol@kde.org>

    SPDX-License-Identifier: LGPL-2.0-or-later
*/

import QtQuick 2.15

import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.kirigami 2.20 as Kirigami

PlasmaComponents.Button {
    id: root

    property int currentIndex: -1

    text: i18n("Desktop Session: %1", instantiator.objectAt(currentIndex > 0 ? currentIndex : 0).text || "")
    // visible: menu.count > 1

    Component.onCompleted: {
        currentIndex = sessionModel.lastIndex
    }
    checkable: true
    checked: menu.opened
    onToggled: {
        if (checked) {
            menu.popup(root, 0, 0)
        } else {
            menu.dismiss()
        }
    }

    signal sessionChanged()

    PlasmaComponents.Menu {
        Kirigami.Theme.colorSet: Kirigami.Theme.Window
        Kirigami.Theme.inherit: false

        id: menu
        Instantiator {
            id: instantiator
            model: sessionModel
            onObjectAdded: (index, object) => menu.insertItem(index, object)
            onObjectRemoved: (index, object) => menu.removeItem(object)
            delegate: PlasmaComponents.MenuItem {
                text: model.name
                onTriggered: {
                    root.currentIndex = model.index
                    sessionChanged()
                }
            }
        }
    }
}
