/*
 *   Copyright 2014 Pier Luigi Fiorini <pierluigi.fiorini@gmail.com>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU Library General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

/*
 * Main procedures
 */

function surfaceMapped(surface) {
    // Determine if it's a shell window
    var firstView = compositor.firstViewOf(surface);
    var isShellWindow =
        (typeof(firstView.role) != "undefined") ||
        (surface.className == "plasmashell.desktop") ||
        (surface.className == "maliit-server.desktop");

    // Print some information
    if (isShellWindow) {
        console.debug("Shell surface", surface, "mapped");
        console.debug("\trole:", firstView.role);
        console.debug("\tsize:", surface.size.width + "x" + surface.size.height);
    } else {
        console.debug("Application surface", surface, "mapped");
        console.debug("\tappId:", surface.className);
        console.debug("\ttitle:", surface.title);
        console.debug("\tsize:", surface.size.width + "x" + surface.size.height);
    }

    // Call a specialized method to deal with application or
    // shell windows
    if (isShellWindow)
        mapShellSurface(surface, firstView);
    else
        mapApplicationSurface(surface);
}

function surfaceUnmapped(surface) {
    // Determine if it's a shell window
    var firstView = compositor.firstViewOf(surface);
    var isShellWindow =
        (typeof(firstView.role) != "undefined") ||
        (surface.className == "plasmashell.desktop") ||
        (surface.className == "maliit-server.desktop");

    // Print some information
    if (typeof(firstView.role) == "undefined") {
        console.debug("Shell surface", surface, "unmapped");
        console.debug("\trole:", firstView.role);
        console.debug("\tsize:", surface.size.width + "x" + surface.size.height);
    } else {
        console.debug("Application surface", surface, "unmapped");
        console.debug("\tappId:", surface.className);
        console.debug("\ttitle:", surface.title);
    }

    // Call a specialized method to deal with application or
    // shell windows
    if (isShellWindow)
        unmapShellSurface(surface);
    else
        unmapApplicationSurface(surface);
}

function surfaceDestroyed(surface) {
    console.debug("Surface", surface, "destroyed");

    // Remove surface from model
    var i;
    for (i = 0; i < surfaceModel.count; i++) {
        var entry = surfaceModel.get(i);

        if (entry.surface === surface) {
            // Destroy window representation and
            // remove the surface from the model
            if (entry.window.chrome)
                entry.window.chrome.destroy();
            entry.window.destroy();
            surfaceModel.remove(i, 1);
            break;
        }
    }
}

/*
 * Map surfaces
 */

function mapApplicationSurface(surface) {
    // Just exit if we already created a window representation
    var i;
    for (i = 0; i < surfaceModel.count; i++) {
        var entry = surfaceModel.get(i);

        if (entry.surface === surface) {
            // Ask the client to resize
            surface.requestSize(window.parent.width, window.parent.height);

            return;
        }
    }

    // Create surface item
    var component = Qt.createComponent("ClientWindowWrapper.qml");
    if (component.status !== Component.Ready) {
        console.error(component.errorString());
        return;
    }

    // Request a view for this output although with phones will
    // likely have just one output
    var child = compositor.viewForOutput(surface, _greenisland_output);

    child.resizeSurfaceToItem = true;
    child.width = compositorRoot.layers.windows.width;
    child.height = compositorRoot.layers.windows.height;

    // Create and setup window container
    var window = component.createObject(compositorRoot.layers.windows, {"child": child});
    compositorRoot.layers.windows.addWindow(window);
    window.child.parent = window;
    window.child.touchEventsEnabled = true;
    window.width = surface.size.width;
    window.height = surface.size.height;

    // Switch to the applications layer and take focus
    compositorRoot.state = "application";
    compositorRoot.currentWindow = window;
    window.child.takeFocus();

    // Run map animation
    if (typeof(window.runMapAnimation) != "undefined")
        window.runMapAnimation();

    // Add surface to the model
    surfaceModel.append({"surface": surface, "window": window});
}

function mapShellSurface(surface, child) {
    // Shell surfaces have only one view which is passed to us
    // as an argument, check whether it's a view for this output
    // or not
    if (child.output !== _greenisland_output)
        return;

    // Just set z-index and exit if we already created a
    // window representation
    var i;
    for (i = 0; i < surfaceModel.count; i++) {
        var entry = surfaceModel.get(i);

        if (entry.surface === surface) {
            // Switch to layer and take focus
            if (surface.className == "plasmashell.desktop" || surface.className == "maliit-server.desktop") {
                compositorRoot.showPanel = true;
            } else {
                compositorRoot.state = "homeScreen";
            }
            entry.window.child.takeFocus();

            return;
        }
    }

    // Create surface item
    var component = Qt.createComponent("ShellWindowWrapper.qml");
    if (component.status !== Component.Ready) {
        console.error(component.errorString());
        return;
    }

    // Create and setup window container
    // XXX: We only support desktop roles for now
    var window = component.createObject(compositorRoot, {"child": child});
    window.parent = (surface.className == "plasmashell.desktop" || surface.className == "maliit-server.desktop") ? compositorRoot.layers.panel : compositorRoot.layers.desktop;
    window.child.parent = window;
    window.child.touchEventsEnabled = true;
    window.x = window.y = 0;
    window.width = surface.size.width;
    window.height = surface.size.height;

    // Switch to the desktop layer and take focus
    compositorRoot.showSplash = false;
    if (surface.className == "plasmashell.desktop" || surface.className == "maliit-server.desktop") {
        compositorRoot.showPanel = true;
    } else {
        compositorRoot.state = "homeScreen";
    }
    window.child.takeFocus();

    // Add surface to the model
    surfaceModel.append({"surface": surface, "window": window});
}

/*
 * Unmap surfaces
 */

function unmapApplicationSurface(surface) {
    // Reactivate home layer as soon as an application window is unmapped
    compositorRoot.state = "homeScreen";
    compositorRoot.currentWindow = null;
}

function unmapShellSurface(surface) {
    // Hide panel layer if this is the sliding panel
    if (surface.className == "plasmashell.desktop" || surface.className == "maliit-server.desktop") {
        compositorRoot.showPanel = false;
    }
}
