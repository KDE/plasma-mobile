import QtQuick 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.shell 2.0 as Shell
import "../components"

Rectangle {
    id: homescreen
    width: 1080
    height: 1920

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

    Component.onCompleted: {
        //configure the view behavior
        desktop.windowType = Shell.Desktop.Window;
        desktop.width = width;
        desktop.height = height;
    }
}
