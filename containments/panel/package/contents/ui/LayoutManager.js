/*
 *   SPDX-FileCopyrightText: 2013 Marco Martin <mart@kde.org>
 *
 *   SPDX-License-Identifier: LGPL-2.0-or-later
 */


var layout;
var root;
var plasmoid;
var lastSpacer;


function restore() {
    var configString = String(plasmoid.configuration.AppletOrder)

    //array, a cell for encoded item order
    var itemsArray = configString.split(";");

    //map applet id->order in panel
    var idsOrder = new Object();
    //map order in panel -> applet pointer
    var appletsOrder = new Object();

    for (var i = 0; i < itemsArray.length; i++) {
        //property name: applet id
        //property value: order
        idsOrder[itemsArray[i]] = i;
    }

    for (var i = 0; i < plasmoid.applets.length; ++i) {
        if (idsOrder[plasmoid.applets[i].id] !== undefined) {
            appletsOrder[idsOrder[plasmoid.applets[i].id]] = plasmoid.applets[i];
        //ones that weren't saved in AppletOrder go to the end
        } else {
            appletsOrder["unordered"+i] = plasmoid.applets[i];
        }
    }

    //finally, restore the applets in the correct order
    for (var i in appletsOrder) {
        root.addApplet(appletsOrder[i], -1, -1)
    }
    //rewrite, so if in the orders there were now invalid ids or if some were missing creates a correct list instead
    save();
}

function save() {
    var ids = new Array();
    for (var i = 0; i < layout.children.length; ++i) {
        var child = layout.children[i];

        if (child.applet) {
            ids.push(child.applet.id);
        }
    }
    plasmoid.configuration.AppletOrder = ids.join(';');
}

function removeApplet (applet) {
    for (var i = layout.children.length - 1; i >= 0; --i) {
        var child = layout.children[i];
        if (child.applet === applet) {
            child.destroy();
        }
    }
}

//insert item2 before item1
function insertBefore(item1, item2) {
    if (item1 === item2) {
        return;
    }
    var removed = new Array();

    var child;

    var i;
    for (i = layout.children.length - 1; i >= 0; --i) {
        child = layout.children[i];
        removed.push(child);
        child.parent = root;

        if (child === item1) {
            break;
        }
    }

    item2.parent = layout;

    for (var j = removed.length - 1; j >= 0; --j) {
        removed[j].parent = layout;
    }
    return i;
}

//insert item2 after item1
function insertAfter(item1, item2) {
    if (item1 === item2) {
        return;
    }
    var removed = new Array();

    var child;

    var i;
    for (i = layout.children.length - 1; i >= 0; --i) {
        child = layout.children[i];
        //never ever insert after lastSpacer
        if (child === lastSpacer && item1 === lastSpacer) {
            removed.push(child);
            child.parent = root;
            break;
        } else if (child === item1) {
            break;
        }

        removed.push(child);
        child.parent = root;
    }

    item2.parent = layout;

    for (var j = removed.length - 1; j >= 0; --j) {
        removed[j].parent = layout;
    }
    return i;
}

function insertAtIndex(item, position) {
    if (position < 0 || position >= layout.children.length) {
        return;
    }

    //never ever insert after lastSpacer
    if (layout.children[position] === lastSpacer) {
        --position;
    }

    var removedItems = new Array();

    for (var i = position; i < layout.children.length; ++i) {
        var child = layout.children[position];
        child.parent = root;
        removedItems.push(child);
    }

    item.parent = layout;
    for (var i in removedItems) {
        removedItems[i].parent = layout;
    }
}

function insertAtCoordinates(item, x, y) {
    if (root.isHorizontal) {
        y = layout.height / 2;
    } else {
        x = layout.width / 2;
    }
    var child = layout.childAt(x, y);

    if (!child || child === item) {
        child = layout.children[0];
    }
    item.parent = root;

    //PlasmaCore.Types.Vertical = 3
    if ((plasmoid.formFactor === 3 && y < child.y + child.height/2) ||
        (plasmoid.formFactor !== 3 && x < child.x + child.width/2)) {
        return insertBefore(child, item);
    } else {
        return insertAfter(child, item);
    }
}
