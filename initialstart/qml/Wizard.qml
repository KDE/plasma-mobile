// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import org.kde.kirigami as Kirigami
import org.kde.plasma.private.mobileshell as MobileShell

import initialstart as InitialStart

Kirigami.Page {
    id: root

    leftPadding: 0
    rightPadding: 0
    topPadding: 0
    bottomPadding: 0

    property var currentModule: InitialStart.Wizard.steps[0]
    readonly property int currentIndex: InitialStart.Wizard.steps.indexOf(currentModule)
    readonly property int stepCount: InitialStart.Wizard.stepsCount
    property bool showingLanding: true

    readonly property var currentStepItem: itemForIndex(currentIndex)
    readonly property var nextStepItem: itemForIndex(currentIndex + 1)
    readonly property var previousStepItem: itemForIndex(currentIndex - 1)

    function itemForIndex(index) {
        if (index < 0 || index >= stepCount || stepsRepeater.count === 0) {
            return null;
        }
        return stepsRepeater.itemAt(InitialStart.Wizard.allSteps.indexOf(InitialStart.Wizard.steps[index]));
    }

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
    }

    Connections {
        target: InitialStart.Wizard

        function onStepsChanged() {
            previousStepAnim.stop();
            currentStepAnim.stop();
            nextStepAnim.stop();
            root.previousStepItemX = 0;
            root.currentStepItemX = 0;
            root.nextStepItemX = 0;

            // keep the selected module unless it is no longer available
            if (!InitialStart.Wizard.steps.includes(root.currentModule)) {
                root.currentModule = InitialStart.Wizard.steps[0];
            }
            if (!root.showingLanding && root.currentStepItem) {
                stepHeading.changeText(root.currentStepItem.name);
            }
        }
    }

    function finishFinalPage() {
        // the app exits
        InitialStart.Wizard.wizardFinished();
    }

    function requestNextPage() {
        if (previousStepAnim.running || currentStepAnim.running || nextStepAnim.running) {
            return;
        }
        if (currentIndex < 0 || onFinalPage) {
            return;
        }

        previousStepItemX = 0;

        currentModule = InitialStart.Wizard.steps[currentIndex + 1];
        stepHeading.changeText(currentStepItem.name);

        currentStepItemX = root.width;

        previousStepAnim.to = -root.width;
        previousStepAnim.restart();
        currentStepAnim.to = 0;
        currentStepAnim.restart();
    }

    function requestPreviousPage() {
        if (previousStepAnim.running || currentStepAnim.running || nextStepAnim.running) {
            return;
        }

        if (currentIndex <= 0) {
            root.showingLanding = true;
            landingComponent.returnToLanding();
        } else {
            nextStepItemX = 0;

            currentModule = InitialStart.Wizard.steps[currentIndex - 1];
            stepHeading.changeText(currentStepItem.name);

            currentStepItemX = -root.width;

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
        width: parent.width
        height: parent.height

        // animation when we switch to step stage
        opacity: root.showingLanding ? 0 : 1
        x: 0
        y: root.showingLanding ? overlaySteps.height : 0

        Behavior on opacity {
            NumberAnimation {
                duration: 1000
                easing.type: Easing.OutExpo
            }
        }

        Behavior on y {
            NumberAnimation {
                duration: 1000
                easing.type: Easing.OutExpo
            }
        }

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
            clip: true

            Kirigami.Theme.inherit: false
            Kirigami.Theme.colorSet: Kirigami.Theme.Window

            color: Kirigami.Theme.backgroundColor
            topLeftRadius: Kirigami.Units.gridUnit
            topRightRadius: Kirigami.Units.gridUnit

            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter

            height: root.height * 0.7
            width: Math.min(parent.width, Kirigami.Units.gridUnit * 30)

            // all steps are in this container
            Item {
                anchors.fill: parent
                anchors.bottomMargin: stepFooter.implicitHeight

                // setup steps
                Repeater {
                    id: stepsRepeater
                    model: InitialStart.Wizard.allSteps

                    delegate: MobileShell.BaseItem {
                        id: item
                        visible: currentIndex >= 0 && (currentIndex === root.currentIndex
                            || (currentIndex === root.currentIndex - 1 && previousStepAnim.running)
                            || (currentIndex === root.currentIndex + 1 && nextStepAnim.running))
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
                        property string name: modelData.name
                        readonly property int currentIndex: InitialStart.Wizard.steps.indexOf(modelData)
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

