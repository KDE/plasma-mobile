// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import org.kde.kirigami 2.20 as Kirigami
import org.kde.plasma.private.mobileshell as MobileShell

import initialstart 1.0 as InitialStart

Kirigami.Page {
    id: root

    leftPadding: 0
    rightPadding: 0
    topPadding: 0
    bottomPadding: 0

    property int currentIndex: 0
    readonly property int stepCount: InitialStart.Wizard.stepsCount
    property bool showingLanding: true

    // filled by items
    property var currentStepItem
    property var nextStepItem
    property var previousStepItem

    readonly property bool onFinalPage: currentIndex === (stepCount - 1)

    // step animation
    // manually doing the animation is more performant and less glitchy with window resize than a SwipeView
    property real previousStepItemX: 0
    property real currentStepItemX: 0
    property real nextStepItemX: 0

    NumberAnimation on previousStepItemX {
        id: previousStepAnim
        duration: 400
        easing.type: Easing.OutExpo
        onFinished: {
            if (root.previousStepItemX != 0) {
                root.previousStepItem.visible = false;
            }
        }
    }

    NumberAnimation on currentStepItemX {
        id: currentStepAnim
        duration: 400
        easing.type: Easing.OutExpo
    }

    NumberAnimation on nextStepItemX {
        id: nextStepAnim
        duration: 400
        easing.type: Easing.OutExpo
        onFinished: {
            if (root.nextStepItemX != 0) {
                root.nextStepItem.visible = false;
            }
        }
    }

    onStepCountChanged: {
        // reset position
        requestPreviousPage();
    }

    function finishFinalPage() {
        // the app exits
        InitialStart.Wizard.wizardFinished();
    }

    function requestNextPage() {
        if (previousStepAnim.running || currentStepAnim.running || nextStepAnim.running) {
            return;
        }

        previousStepItemX = 0;

        currentIndex++;
        stepHeading.changeText(currentStepItem.name);

        currentStepItemX = root.width;
        currentStepItem.visible = true;

        previousStepAnim.to = -root.width;
        previousStepAnim.restart();
        currentStepAnim.to = 0;
        currentStepAnim.restart();
    }

    function requestPreviousPage() {
        if (previousStepAnim.running || currentStepAnim.running || nextStepAnim.running) {
            return;
        }

        if (currentIndex === 0) {
            root.showingLanding = true;
            landingComponent.returnToLanding();
        } else {
            nextStepItemX = 0;

            currentIndex--;
            stepHeading.changeText(currentStepItem.name);

            currentStepItemX = -root.width;
            currentStepItem.visible = true;

            nextStepAnim.to = root.width;
            nextStepAnim.restart();
            currentStepAnim.to = 0;
            currentStepAnim.restart();
        }
    }

    LandingComponent {
        id: landingComponent
        anchors.fill: parent

        onRequestNextPage: {
            root.showingLanding = false;
            stepHeading.changeText(root.currentStepItem.name);
        }
    }

    Item {
        id: stepsComponent
        anchors.fill: parent

        // animation when we switch to step stage
        opacity: root.showingLanding ? 0 : 1
        property real translateY: root.showingLanding ? overlaySteps.height : 0

        Behavior on opacity {
            NumberAnimation {
                duration: 1000
                easing.type: Easing.OutExpo
            }
        }

        Behavior on translateY {
            NumberAnimation {
                duration: 1000
                easing.type: Easing.OutExpo
            }
        }

        transform: Translate { y: stepsComponent.translateY }

        // heading for all the wizard steps
        Label {
            id: stepHeading
            opacity: 0
            color: "white"
            horizontalAlignment: Text.AlignHCenter
            font.pointSize: 18

            anchors.left: parent.left
            anchors.leftMargin: Kirigami.Units.gridUnit
            anchors.right: parent.right
            anchors.rightMargin: Kirigami.Units.gridUnit
            anchors.bottom: parent.bottom
            anchors.bottomMargin: root.height * 0.7 + Kirigami.Units.gridUnit

            property string toText

            function changeText(text) {
                toText = text;
                toHidden.restart();
            }

            NumberAnimation on opacity {
                id: toHidden
                duration: 200
                to: 0
                onFinished: {
                    stepHeading.text = stepHeading.toText;
                    toShown.restart();
                }
            }

            NumberAnimation on opacity {
                id: toShown
                duration: 200
                to: 1
            }
        }

        Rectangle {
            id: overlaySteps

            Kirigami.Theme.inherit: false
            Kirigami.Theme.colorSet: Kirigami.Theme.Window

            color: Kirigami.Theme.backgroundColor

            anchors.fill: parent
            anchors.topMargin: root.height * 0.3

            // all steps are in this container
            Item {
                anchors.fill: parent
                anchors.bottomMargin: stepFooter.implicitHeight

                // setup steps
                Repeater {
                    model: InitialStart.Wizard.steps

                    delegate: MobileShell.BaseItem {
                        id: item
                        visible: model.index === 0 // the binding is broken later
                        contentItem: modelData.contentItem
                        transform: Translate {
                            x: {
                                if (item.currentIndex === root.currentIndex - 1) {
                                    return previousStepItemX;
                                } else if (item.currentIndex === root.currentIndex + 1) {
                                    return nextStepItemX;
                                } else if (item.currentIndex === root.currentIndex) {
                                    return currentStepItemX;
                                }
                                return 0;
                            }
                        }

                        anchors.fill: parent

                        // pass up the property
                        property string name: contentItem.name
                        property int currentIndex: model.index

                        function updateRootItems() {
                            if (model.index === root.currentIndex) {
                                root.currentStepItem = item;
                            } else if (model.index === root.currentIndex - 1) {
                                root.previousStepItem = item;
                            } else if (model.index === root.currentIndex + 1) {
                                root.nextStepItem = item;
                            }
                        }

                        Component.onCompleted: {
                            updateRootItems();
                        }

                        // keep root properties updated
                        Connections {
                            target: root

                            function onCurrentIndexChanged() {
                                item.updateRootItems();
                            }
                        }
                    }
                }
            }

            // bottom footer
            RowLayout {
                id: stepFooter
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right

                Button {
                    Layout.alignment: Qt.AlignLeft
                    Layout.leftMargin: Kirigami.Units.gridUnit
                    Layout.bottomMargin: Kirigami.Units.gridUnit

                    topPadding: Kirigami.Units.largeSpacing
                    bottomPadding: Kirigami.Units.largeSpacing
                    leftPadding: Kirigami.Units.gridUnit
                    rightPadding: Kirigami.Units.gridUnit

                    text: i18n("Back")
                    icon.name: "arrow-left"

                    onClicked: root.requestPreviousPage()
                }

                Item {}

                Button {
                    Layout.alignment: Qt.AlignRight
                    Layout.rightMargin: Kirigami.Units.gridUnit
                    Layout.bottomMargin: Kirigami.Units.gridUnit

                    topPadding: Kirigami.Units.largeSpacing
                    bottomPadding: Kirigami.Units.largeSpacing
                    leftPadding: Kirigami.Units.gridUnit
                    rightPadding: Kirigami.Units.gridUnit

                    visible: !root.onFinalPage
                    text: i18n("Next")
                    icon.name: "arrow-right"

                    onClicked: root.requestNextPage();
                }

                Button {
                    Layout.alignment: Qt.AlignRight
                    Layout.rightMargin: Kirigami.Units.gridUnit
                    Layout.bottomMargin: Kirigami.Units.gridUnit

                    topPadding: Kirigami.Units.largeSpacing
                    bottomPadding: Kirigami.Units.largeSpacing
                    leftPadding: Kirigami.Units.gridUnit
                    rightPadding: Kirigami.Units.gridUnit

                    visible: root.onFinalPage
                    text: i18n("Finish")
                    icon.name: "dialog-ok"

                    onClicked: root.finishFinalPage();
                }
            }
        }
    }
}

