/*
    SPDX-FileCopyrightText: 2014-2015 Harald Sitter <sitter@kde.org>

    SPDX-License-Identifier: LGPL-2.1-only OR LGPL-3.0-only OR LicenseRef-KDE-Accepted-LGPL
*/

// from https://invent.kde.org/plasma/plasma-pa/-/blob/master/applet/contents/code/icon.js
function name(volume, muted, prefix) {
    if (!prefix) {
        prefix = "audio-volume";
    }
    var icon = null;
    var percent = volume / 100;
    if (percent <= 0.0 || muted) {
        icon = prefix + "-muted";
    } else if (percent <= 0.25) {
        icon = prefix + "-low";
    } else if (percent <= 0.75) {
        icon = prefix + "-medium";
    } else {
        icon = prefix + "-high";
    }
    return icon;
}

