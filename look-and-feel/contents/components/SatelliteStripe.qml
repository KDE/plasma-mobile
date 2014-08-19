import QtQuick 2.0
import org.kde.plasma.core 2.0 as PlasmaCore

Rectangle {
    color: "white" // FIXME
    opacity: .5
    height: Math.max(100, units.gridUnit * 2.5)
    width: parent.width
    y: parent.height / 2 - height / 2
    x: 0
}
