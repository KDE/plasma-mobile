/****************************************************************************
**
** Copyright (C) 2014 Digia Plc and/or its subsidiary(-ies).
** Contact: http://www.qt-project.org/legal
**
** This file is part of the examples of the Qt Toolkit.
**
** $QT_BEGIN_LICENSE:BSD$
** You may use this file under the terms of the BSD license as follows:
**
** "Redistribution and use in source and binary forms, with or without
** modification, are permitted provided that the following conditions are
** met:
**   * Redistributions of source code must retain the above copyright
**     notice, this list of conditions and the following disclaimer.
**   * Redistributions in binary form must reproduce the above copyright
**     notice, this list of conditions and the following disclaimer in
**     the documentation and/or other materials provided with the
**     distribution.
**   * Neither the name of Digia Plc and its Subsidiary(-ies) nor the names
**     of its contributors may be used to endorse or promote products derived
**     from this software without specific prior written permission.
**
**
** THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
** "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
** LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
** A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
** OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
** SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
** LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
** DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
** THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
** (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
** OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE."
**
** $QT_END_LICENSE$
**
****************************************************************************/

import QtQuick 2.4
import QtMultimedia 5.4
import org.kde.plasma.core 2.0 as PlasmaCore

FocusScope {
    property Camera camera
    property bool previewAvailable : false

    property int buttonsPanelWidth: buttonPaneShadow.width

    signal previewSelected
    signal photoModeSelected
    id : captureControls

    PlasmaCore.FrameSvgItem {
        id: buttonPaneShadow
        imagePath: "widgets/background"
        enabledBorders: PlasmaCore.FrameSvgItem.RightBorder
        width: bottomColumn.width + 16 + margins.right
        height: parent.height
        anchors.top: parent.top
        x: menuShown ? 0 : -width
        Behavior on x {
            XAnimator {
                duration: units.shortDuration
                easing.type: Easing.InOutQuad
            }
        }

        Column {
            anchors {
                left: parent.left
                top: parent.top
                margins: 8
            }

            id: buttonsColumn
            spacing: 8

            FocusButton {
                camera: captureControls.camera
                visible: camera.cameraStatus == Camera.ActiveStatus && camera.focus.isFocusModeSupported(Camera.FocusAuto)
            }

            CameraButton {
                text: "View"
                onClicked: captureControls.previewSelected()
                //don't show View button during recording
                visible: camera.videoRecorder.actualLocation && !stopButton.visible
            }
        }

        Column {
            anchors {
                bottom: parent.bottom
                left: parent.left
                margins: 8
            }

            id: bottomColumn
            spacing: 8

            CameraListButton {
                model: QtMultimedia.availableCameras
                onValueChanged: captureControls.camera.deviceId = value
            }

            CameraButton {
                id: switchButton
                text: "Switch to Photo"
                onClicked: captureControls.photoModeSelected()
            }

            Item {
                width: 1
                height: switchButton.height
            }
        }
    }

    CameraButton {
        anchors {
            margins: 8
            horizontalCenter: parent.horizontalCenter
            bottom: parent.bottom
        }
        text: camera.videoRecorder.recorderStatus == CameraRecorder.RecordingStatus ? "Stop" : "Record"
        onClicked: {
            if (camera.videoRecorder.recorderStatus == CameraRecorder.RecordingStatus) {
                camera.videoRecorder.stop();
            } else {
                camera.videoRecorder.record();
            }
        }
    }

    CameraButton {
        z: 99
        anchors {
            margins: 8
            left: parent.left
            bottom: parent.bottom
        }
        text: "Menu"
        onClicked: menuShown = !menuShown
    }

    ZoomControl {
        x : 0
        y : 0
        width : 100
        height: parent.height

        currentZoom: camera.digitalZoom
        maximumZoom: Math.min(4.0, camera.maximumDigitalZoom)
        onZoomTo: camera.setDigitalZoom(value)
    }
}
