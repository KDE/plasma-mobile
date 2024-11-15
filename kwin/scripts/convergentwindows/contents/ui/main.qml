// SPDX-FileCopyrightText: 2023 Plata Hill <plata.hill@kdemail.net>
// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.1-or-later

import QtQuick
import org.kde.kwin as KWinComponents
import org.kde.plasma.private.mobileshell.shellsettingsplugin as ShellSettings

// This script ensures that windows stay maximized in the shell.
//
// We eventually want to replace this with the window rules implementation,
// but it seems that window maximize rules still don't work for all cases just yet
// (ex. unmaximizing fullscreen window)
Loader {
    id: root

    property var currentWindow

    function run(window) {
        // HACK: don't maximize xwaylandvideobridge
        // see: https://invent.kde.org/plasma/plasma-mobile/-/issues/324
        if (window.resourceClass === 'xwaylandvideobridge') {
            return;
        }

        if (!window.normalWindow) {
            return;
        }

        if (ShellSettings.Settings.convergenceModeEnabled) {
            return;
        }

        if (!window.fullScreen) {
            const output = window.output;
            const desktop = window.desktops[0]; // assume it's the first desktop that the window is on
            if (desktop === undefined) {
                return;
            }
            const maximizeRect = KWinComponents.Workspace.clientArea(KWinComponents.Workspace.MaximizeArea, output, desktop);

            // set the window to the maximized size and position instantly, avoiding race condition
            // between maximizing and window decorations being turned off (changing window height)
            // see: https://invent.kde.org/teams/plasma-mobile/issues/-/issues/256
            window.frameGeometry = maximizeRect;
        }

        if (!window.fullScreen) {
            // run maximize after to ensure the state is maximized
            window.setMaximize(true, true);
        }
    }

    Connections {
        target: currentWindow

        function onFullScreenChanged() {
            currentWindow.interactiveMoveResizeFinished.connect((currentWindow) => {
                root.run(currentWindow);
            });
            root.run(currentWindow);
        }

        function onMaximizedChanged() {
            if (!currentWindow.maximizable) {
                return;
            }
            currentWindow.interactiveMoveResizeFinished.connect((currentWindow) => {
                root.run(currentWindow);
            });
            root.run(currentWindow);
        }
    }

    Connections {
        target: ShellSettings.Settings

        function onConvergenceModeEnabledChanged() {
            const windows = KWinComponents.Workspace.windows;

            for (let i = 0; i < windows.length; i++) {
                if (windows[i].normalWindow) {
                    root.run(windows[i]);
                }
            }
        }
    }

    Connections {
        target: KWinComponents.Workspace

        function onWindowAdded(window) {
            if (window.normalWindow) {
                window.interactiveMoveResizeFinished.connect((window) => {
                    root.run(window);
                });
                root.run(window);
            }
        }

        function onWindowActivated(window) {
            if (window.normalWindow) {
                currentWindow = window;
                window.interactiveMoveResizeFinished.connect((window) => {
                    root.run(window);
                });
                root.run(window);
            }
        }

        function onScreensChanged() {
            // Windows are moved from the external screen
            // to the internal screen if the external screen
            // is disconnected.
            const windows = KWinComponents.Workspace.windows;

            for (var i = 0; i < windows.length; i++) {
                if (windows[i].normalWindow) {
                    root.run(windows[i]);
                }
            }
        }
    }
}
