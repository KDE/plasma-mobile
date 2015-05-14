import QtQuick 2.0
import org.kde.plasma.core 2.0 as PlasmaCore

PlasmaCore.ColorScope {
    colorGroup: PlasmaCore.Theme.NormalColorGroup

    PlasmaCore.FrameSvgItem {
        z: -1
        imagePath: "widgets/background"
        enabledBorders: PlasmaCore.FrameSvgItem.TopBorder | PlasmaCore.FrameSvgItem.BottomBorder
        anchors {
            fill: parent
            topMargin: -margins.top
            bottomMargin: -margins.bottom
        }
        Rectangle {
            anchors {
                fill: parent
                topMargin: parent.margins.top
                bottomMargin: parent.margins.bottom
            }
            color: PlasmaCore.ColorScope.backgroundColor
        }
    }

    height: applicationsView.cellWidth
    width: parent.width
    y: parent.height / 2 - height / 2
    x: 0
}
