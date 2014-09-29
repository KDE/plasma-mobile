import QtQuick 2.0
import org.kde.plasma.core 2.0 as PlasmaCore

Rectangle {
    id: root

    color: "#00000000"
    height: units.gridUnit * 2
    width: parent.width
    anchors.bottomMargin: 10

    property var textGradient: Gradient {
                GradientStop { position: 1.0; color: "#FF00000C" }
                GradientStop { position: 0.0; color: "#00000C00" }
            }
    property color textGradientOverlay: "#9900000C"

    PlasmaCore.IconItem {
        id: icon
        width: units.iconSizes.medium
        height: width
        x: units.largeSpacing
        y: 0
        source: "im-user"
    }

    Item {
        id: rounded
        clip: true
        height: parent.height
        width: height / 2
        anchors {
            left: icon.right
            leftMargin: units.largeSpacing
        }

        Rectangle {
            height: parent.height
            width: parent.width * 2
            radius: height
            anchors {
                left: parent.left
                top: parent.top
            }

            gradient: root.textGradient

            Rectangle {
                anchors.fill: parent
                radius: height / 2
                color: textGradientOverlay
            }
        }
    }

    Rectangle {
        id: summaryArea
        width: parent.width - icon.width - rounded.width - (units.largeSpacing * 2)
        height: parent.height

        anchors {
            left: rounded.right
            top: parent.top
        }

        gradient: root.textGradient
        Rectangle {
            anchors.fill: parent
            color: textGradientOverlay
        }

        Text {
            anchors.fill: parent
            horizontalAlignment: Qt.AlignLeft
            verticalAlignment: Qt.AlignVCenter
            color: "white"
            text: summary
        }
/*
        MouseArea {
            anchors.fill: parent
            drag.axis: Drag.YAxis
            drag.target: parent
        }*/
    }
}