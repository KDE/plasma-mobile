// SPDX-FileCopyrightText: 2021-2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick
import QtQuick.Controls
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Templates as T

import org.kde.kirigami as Kirigami

Item {
    id: root
    property alias from: spinBox.from
    property alias to: spinBox.to
    property alias value: spinBox.value

    signal valueModified()

    T.SpinBox {
        id: spinBox
        visible: false
        stepSize: 1

        onValueModified: root.valueModified()

        validator: IntValidator {
            locale: spinBox.locale.name
            bottom: Math.min(spinBox.from, spinBox.to)
            top: Math.max(spinBox.from, spinBox.to)
        }
    }

    Kirigami.Theme.colorSet: Kirigami.Theme.Button
    Kirigami.Theme.inherit: false

    implicitWidth: Kirigami.Units.gridUnit * 4
    implicitHeight: column.implicitHeight

    readonly property color buttonColor: Kirigami.Theme.backgroundColor
    readonly property color buttonHoverColor: Qt.darker(buttonColor, 1.05)
    readonly property color buttonPressedColor: Qt.darker(buttonColor, 1.2)
    readonly property color buttonBorderColor: Qt.alpha(Kirigami.Theme.textColor, 0.3)

    ColumnLayout {
        id: column
        spacing: 0
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right

        TimePickerSpinBoxButton {
            Layout.fillWidth: true
            onClicked: {
                spinBox.increase();
                spinBox.valueModified();
            }
            icon.name: 'arrow-up-symbolic'
            isStart: true
            isEnd: false
            enabled: spinBox.value < spinBox.to
        }

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: textInput.implicitHeight

            Kirigami.Theme.inherit: false
            Kirigami.Theme.colorSet: Kirigami.Theme.Button
            color: Kirigami.Theme.backgroundColor

            Rectangle {
                width: 1
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                color: Kirigami.ColorUtils.linearInterpolation(Kirigami.Theme.backgroundColor, Kirigami.Theme.textColor, 0.15)
            }

            Rectangle {
                width: 1
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                color: Kirigami.ColorUtils.linearInterpolation(Kirigami.Theme.backgroundColor, Kirigami.Theme.textColor, 0.15)
            }


            MouseArea {
                anchors.fill: parent
                propagateComposedEvents: true
                property int wheelDelta: 0

                onExited: wheelDelta = 0
                onWheel: {
                    wheelDelta += wheel.angleDelta.y;
                    // magic number 120 for common "one click"
                    // See: http://qt-project.org/doc/qt-5/qml-qtquick-wheelevent.html#angleDelta-prop
                    while (wheelDelta >= 120) {
                        wheelDelta -= 120;
                        spinBox.increase();
                        spinBox.valueModified();
                    }
                    while (wheelDelta <= -120) {
                        wheelDelta += 120;
                        spinBox.decrease();
                        spinBox.valueModified();
                    }
                }

                // Normally the TextInput does this automatically, but the MouseArea on
                // top of it blocks that behavior, so we need to explicitly do it here
                cursorShape: Qt.IBeamCursor

                TextInput {
                    id: textInput
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    font.pointSize: Math.round(Kirigami.Theme.defaultFont.pointSize * 2.5)
                    font.weight: Font.Light

                    color: Kirigami.Theme.textColor
                    selectionColor: Kirigami.Theme.highlightColor
                    selectedTextColor: Kirigami.Theme.highlightedTextColor
                    selectByMouse: true
                    horizontalAlignment: Qt.AlignHCenter
                    verticalAlignment: Qt.AlignVCenter

                    inputMethodHints: Qt.ImhFormattedNumbersOnly

                    function applyTextBinding() {
                        text = Qt.binding(function () { return spinBox.displayText.length == 1 ? '0' + spinBox.displayText : spinBox.displayText });
                    }

                    Component.onCompleted: applyTextBinding()
                    onEditingFinished: {
                        spinBox.value = parseInt(text);
                        spinBox.valueModified();
                        applyTextBinding();
                    }
                }
            }
        }

        TimePickerSpinBoxButton {
            Layout.fillWidth: true
            onClicked: {
                spinBox.decrease();
                spinBox.valueModified();
            }
            icon.name: 'arrow-down-symbolic'
            isStart: false
            isEnd: true
            enabled: spinBox.value > spinBox.from
        }
    }
}
