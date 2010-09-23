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
import Plasma 0.1 as Plasma
import GraphicsLayouts 4.7

QGraphicsWidget {
    id: page;
    preferredSize: "250x600"
    minimumSize: "200x200"

    function init()
    {
        global.addEventListener('ConfigChanged', configChanged);
        global.addEventListener("addoncreated", addonCreated)

        var addons = global.listAddons("org.kde.plasma.javascript-addons-example")

        if (addons.length < 1) {
            // uh-oh, something didn't work!
            print("You probably need to run `plasmapkg -t Plasma/JavascriptAddon -i exampleAddon && kbuildsycoca4`")
        } else {
            print("number of addons: "+ addons.length)

            print(global.loadAddon("org.kde.plasma.javascript-addons-example", addons[0].id))
        }
    }

    function addonCreated(addon)
    {
        print("Addon says: "+ addon.toString())
        if (addon.svg) {
            var svg = new SvgWidget
            svg.svg = addon.svg
        }
    }

    function configChanged()
    {
        print("Configuration changed listener");
    }

    layout: QGraphicsLinearLayout {
        Plasma.Label {
            text: "Testing Javascript addons"
        }

        Plasma.SvgWidget {
            
        }
    }
}
