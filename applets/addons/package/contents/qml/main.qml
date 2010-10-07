/*
 *   Copyright 2010 Marco Martin <notmart@gmail.com>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import Qt 4.7
import org.kde.plasma.graphicswidgets 0.1 as PlasmaWidgets
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.graphicslayouts 4.7 as GraphicsLayouts

QGraphicsWidget {
    id: page;
    preferredSize: "250x600"
    minimumSize: "200x200"

    Item {
        PlasmaCore.Svg {
            id:svgExample
            imagePath: "widgets/clock"
        }
    }

    Component.onCompleted: {
        plasmoid.addEventListener('ConfigChanged', configChanged)
        plasmoid.addEventListener("addoncreated", addonCreated)
        plasmoid.addEventListener("initExtenderItem", initExtenderItem)

        print(i18n("Translated message"));

        var addons = plasmoid.listAddons("org.kde.plasma.javascript-addons-example")

        if (addons.length < 1) {
            // uh-oh, something didn't work!
            print("You probably need to run `plasmapkg -t Plasma/JavascriptAddon -i exampleAddon && kbuildsycoca4`")
        } else {
            print("number of addons: "+ addons.length)

            print(plasmoid.loadAddon("org.kde.plasma.javascript-addons-example", addons[0].id))
        }

        var e = plasmoid.extender()
        if (e.hasItem("yes!")) {
            print(i18n("We already have our extender, it will be recreated for us. Expect a call to initEtenderItem."));
        } else {
            // new ExtenderItems are automatically added to our widget's Extender
            var ext = new ExtenderItem
            ext.name = "yes!"
            initExtenderItem(ext)
        }
    }

    function initExtenderItem(item)
    {
        extenderButton.text = i18n("Hello")
        item.widget = extenderButton
        print(i18n("Widget in Extender '%1' has text '%2'", item.name, extenderButton.text))
    }

    function addonCreated(addon)
    {
        print("Addon says: " + addon.toString());
        label.text = addon.toString()
        if (addon.svg) {
            svgWidget.svg = addon.svg
        }
    }

    function configChanged()
    {
        print("Configuration changed listener");
    }

    function openFileDialogAccepted(dialog)
    {
        var url = dialog.url
        print("open this file! " + url.protocol + ' ' + url.host + ' ' + url.path)

        if (plasmoid['openUrl']) {
            plasmoid.openUrl(url);
        } else {
            print("no openUrl method available to us!")
        }
    }

    function openFileDialogFinished(dialog)
    {
        dialog.accepted.disconnect(openFileDialogAccepted)
        dialog.finished.disconnect(openFileDialogFinished)
        plasmoid.gc()
    }

    PlasmaWidgets.PushButton {
        id: extenderButton
    }

    layout: GraphicsLayouts.QGraphicsLinearLayout {
        orientation: Qt.Vertical
        PlasmaWidgets.Label {
            id: label
            text: "Testing Javascript addons"
        }

        PlasmaWidgets.PushButton {
            id: openButton
            text: "Open File"
            icon: QIcon("document-open")
            onClicked: {
                print("opening a file?")
                var dialog = new OpenFileDialog()
                print(dialog)
                dialog.accepted.connect(openFileDialogAccepted)
                dialog.finished.connect(openFileDialogFinished)
                dialog.show()
            }
        }

        PlasmaWidgets.SvgWidget {
            id: svgWidget
        }
    }

}
