/*
 *  SPDX-FileCopyrightText: 2013 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick 2.0
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.3 as QtControls
import QtQuick.Window 2.2

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.kquickcontrolsaddons 2.0
import org.kde.kirigami 2.5 as Kirigami

MouseArea {
    id: delegate

//BEGIN properties
    implicitWidth: delegateContents.implicitWidth + 4 * PlasmaCore.Units.smallSpacing
    implicitHeight: delegateContents.height + PlasmaCore.Units.smallSpacing * 4
    Layout.fillWidth: true
    hoverEnabled: true

    property bool current: (model.kcm && pageStack.currentItem.kcm && model.kcm == pageStack.currentItem.kcm) || (model.source == pageStack.sourceFile)
//END properties

//BEGIN functions
    function openCategory() {
        if (current) {
            return;
        }
        if (typeof(categories.currentItem) !== "undefined") {
            pageStack.invertAnimations = (categories.currentItem.x > delegate.x);
            categories.currentItem = delegate;
        }

        if (model.source) {
            pageStack.sourceFile = model.source;
        } else if (model.kcm) {
            pageStack.sourceFile = "";
            pageStack.sourceFile = Qt.resolvedUrl("ConfigurationKcmPage.qml");
            pageStack.currentItem.kcm = model.kcm;
        } else {
            pageStack.sourceFile = "";
        }
        pageStack.title = model.name
    }
//END functions

//BEGIN connections
    onPressed: {
        categoriesScroll.forceActiveFocus()

        if (current) {
            return;
        }

        openCategory();
    }
    onCurrentChanged: {
        if (current) {
            categories.currentItem = delegate;
        }
    }
//END connections

//BEGIN UI components
    Rectangle {
        anchors.fill: parent
        color: Kirigami.Theme.highlightColor
        opacity: { // try to match Breeze style hover handling
            var active = categoriesScroll.activeFocus && Window.active
            if (current) {
                if (active) {
                    return 1
                } else if (delegate.containsMouse) {
                    return 0.6
                } else {
                    return 0.3
                }
            } else if (delegate.containsMouse) {
                if (active) {
                    return 0.3
                } else {
                    return 0.1
                }
            }
            return 0
        }
        Behavior on opacity {
            NumberAnimation {
                duration: PlasmaCore.Units.longDuration
                easing.type: Easing.InOutQuad
            }
        }
    }

    ColumnLayout {
        id: delegateContents
        spacing: PlasmaCore.Units.smallSpacing
        width: parent.width
        anchors.verticalCenter: parent.verticalCenter

        QIconItem {
            id: iconItem
            Layout.alignment: Qt.AlignHCenter
            width: PlasmaCore.Units.iconSizes.medium
            height: width
            icon: model.icon
            state: current && categoriesScroll.activeFocus ? QIconItem.SelectedState : QIconItem.DefaultState
        }

        QtControls.Label {
            id: nameLabel
            Layout.fillWidth: true
            text: model.name
            wrapMode: Text.Wrap
            horizontalAlignment: Text.AlignHCenter
            color: current && categoriesScroll.activeFocus ? Kirigami.Theme.highlightedTextColor : Kirigami.Theme.textColor
            Behavior on color {
                ColorAnimation {
                    duration: PlasmaCore.Units.longDuration
                    easing.type: Easing.InOutQuad
                }
            }
        }
    }
//END UI components
}

