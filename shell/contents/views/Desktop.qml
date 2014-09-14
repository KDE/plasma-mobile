import QtQuick 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import "../components"

Rectangle {
    id: homescreen
    width: 1024
    height: 768

    property Item containment;
    property Item wallpaper;

    onContainmentChanged: console.log(containment.pluginName)
    onWallpaperChanged: {
        console.log(wallpaper.pluginName + ' ' + wallpaper.opacity);
    }

    SatelliteStripe {
        id: stripe
        z: 1

        MouseArea {
            anchors.fill: parent
            onPressed: {
            }

            onReleased: {
            }
        }
    }
}
