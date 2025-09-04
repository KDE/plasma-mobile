// SPDX-FileCopyrightText: Sebastian Kügler <sebas@kde.org>
// SPDX-License-Identifier: LGPL-2.1-or-later
/**
 * This script is run when Plasma Mobile switches to docked mode.
 * It does two things:
 *  - resets the placementCallback to null, so we have KWin decide
 *    what to do with new windows
 *  - switches on border for existing, normal windows
 *
 * It basically undoes what the mobilewindows script did.
 *
 */

function init() {
    const windows = workspace.stackingOrder;
    for (var i = 0; i < windows.length; i++) {
        var window = windows[i];
        if (window.normalWindow) {
            window.noBorder = false;
        }
    }
}

workspace.setPlacementCallback(null);

init();
