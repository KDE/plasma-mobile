import QtQuick 2.0
import org.kde.plasma.core 2.0 as PlasmaCore

Rectangle {
    color: "black" // FIXME
    opacity: 0.6
    height: Math.max(100, units.gridUnit * 2.5)
    width: parent.width
    y: parent.height / 2 - height / 2
    x: 0
}
