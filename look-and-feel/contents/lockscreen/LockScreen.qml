import QtQuick 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import "../components"

Leaves {
    id: lockscreen

    PlasmaCore.Svg {
        id: symbolsSvg
        imagePath:  Qt.resolvedUrl("images/symbols.svgz")
    }

    MouseArea {
        anchors.fill: parent
        onPressed: {
            stripe.visible = true;
        }
    }

    SatelliteStripe {
        id: stripe
        visible: false
        opacity: 0

        onVisibleChanged: {
            opacity = visible ? 1 : 0;
        }

        Behavior on opacity {
            NumberAnimation {
                duration: 300
                easing.type: Easing.InOutQuad
            }
        }

        PlasmaCore.SvgItem {
            id: square
            property int value: 1
            opacity: 1
            anchors.top: parent.top
            anchors.left: parent.left
            width: parent.width/4
            height: parent.height

            svg: symbolsSvg
            elementId: "square"

            MouseArea {
                anchors.fill: parent
                onPressed: {
                    console.log("square");
                }
            }
        }

        PlasmaCore.SvgItem {
            id: circle
            property int value: 2
            anchors.top: parent.top
            anchors.left: square.right
            width: square.width
            height: square.height

            svg: symbolsSvg
            elementId: "circle"

            MouseArea {
                anchors.fill: parent
                onPressed: {
                    console.log("circle");
                }
            }
        }

        PlasmaCore.SvgItem {
            id: ex
            property int value: 3
            anchors.top: parent.top
            anchors.left: circle.right
            width: square.width
            height: square.height

            svg: symbolsSvg
            elementId: "ex"

            MouseArea {
                anchors.fill: parent
                onPressed: {
                    console.log("ex");
                }
            }
        }

        PlasmaCore.SvgItem {
            id: triangle
            property int value: 4
            anchors.top: parent.top
            anchors.left: ex.right
            width: parent.width - (square.width * 3)
            height: square.height

            svg: symbolsSvg
            elementId: "triangle"

            MouseArea {
                anchors.fill: parent
                onPressed: {
                    console.log("triangle");
                }
            }
        }
    }
}
