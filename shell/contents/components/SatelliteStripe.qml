import QtQuick 2.0
import org.kde.plasma.core 2.0 as PlasmaCore

Item {
    PlasmaCore.FrameSvgItem {
        z: -1
        imagePath: "widgets/background"
        enabledBorders: PlasmaCore.FrameSvgItem.TopBorder | PlasmaCore.FrameSvgItem.BottomBorder
        anchors {
            fill: parent
            topMargin: -margins.top
            bottomMargin: -margins.bottom
        }
    }

    opacity: 0.6
    height: Math.max(100, units.gridUnit * 2.5)
    width: parent.width
    y: parent.height / 2 - height / 2
    x: 0
}
