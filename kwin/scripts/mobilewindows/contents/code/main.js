// SPDX-FileCopyrightText: Sebastian Kügler <sebas@kde.org>
// SPDX-License-Identifier: LGPL-2.1-or-later
/**
 * This script is run when Plasma Mobile switches to mobile (non-docked mode.
 * It does two things:
 *  - sets a placementCallback that maximizes new normal windows and removes
 *    their border (except for modal windows, which keep border and are centered)
 *  - switches off border for existing, normal windows and maximizes them
 *
 */

function dbg(msg) {
    console.debug("[mobile] kwin_scripting::js " + msg);
}

function analyze_window(w) {
    if (!w) {
        dbg("Window undefined or somesuch!");
        return;
    }
    dbg("___ Caption: " + w.caption + "______________");
    dbg("       windowRole: " + w.windowRole);
    dbg("     normalWindow: " + w.normalWindow);
    dbg("           dialog: " + w.dialog);
    dbg("          utility: " + w.utility);
    dbg("    specialWindow: " + w.specialWindow);
    dbg("            modal: " + w.modal);
    dbg("____________________________________________");
}


function place(options) {

    let empty_rect = {};
    let window = options.window;
    dbg("place() " + window.caption);

    analyze_window(window);

    if (!window || !window.normalWindow) {
        dbg("not normal: " + window.caption);
        return empty_rect;
    }

    if (window.resourceClass === 'xwaylandvideobridge') {
        return empty_rect;
    }

    let clientArea = options.area;

    if (!window.modal) {
        dbg("non-modal, no border, big " + window.caption);
        window.noBorder = true;
        window.frameGeometry = clientArea;
        return clientArea

    } else {
        window.noBorder = false;

        let w_width = clientArea.width / 1.5;
        let w_height = clientArea.height / 1.5;
        let _x = (clientArea.width - w_width) / 2;
        let _y = (clientArea.height - w_height) / 2;
        let frameGeometry = {x: _x, y: _y, width: w_width, height: w_height };
        window.frameGeometry = frameGeometry;
        return frameGeometry;
    }

    return empty_rect;
}

function init() {
    const windows = workspace.stackingOrder;
    dbg("init, " + windows.length + " windows");
    for (let i = 0; i < windows.length; i++) {
        let window = windows[i];
        analyze_window(window);
        if (!window.modal) {
            window.noBorder = true;
            dbg("init w: " + window.caption+ " noBorder");
            const output = window.output;
            const desktop = window.desktops[0]; // assume it's the first desktop that the window is on
            if (desktop === undefined) {
                continue;
            }
            const maximizeRect = workspace.clientArea(workspace.MaximizeArea, output, desktop);
            window.frameGeometry = maximizeRect;
        }
    }
}

workspace.setPlacementCallback(place);

init();
