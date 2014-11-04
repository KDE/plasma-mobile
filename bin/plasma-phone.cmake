#!/bin/sh
#
# Script that starts the Plasma phone UI.
#
# Copyright (C) 2014 Pier Luigi Fiorini <pierluigi.fiorini@gmail.com>
#
# This program is free software; you can redistribute it and/or modify it
# under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation; either version 2.1 of the License, or
# (at your option) any later version.
#

## Compositor

export EGL_PLATFORM=hwcomposer
export QT_QPA_PLATFORM=hwcomposer
export QT_QPA_EGLFS_DEPTH=32
export QT_QPA_EGLFS_HIDECURSOR=1
export QT_COMPOSITOR_NEGATE_INVERTED_Y=0
export KSCREEN_BACKEND=QScreen

/usr/bin/greenisland -plugin evdevtouch:/dev/input/event1 -plugin evdevkeyboard:keymap=/usr/share/qt5/keymaps/droid.qmap -p org.kde.satellite.compositor.phone &

sleep 3

## UI

unset EGL_PLATFORM
unset QT_QPA_PLATFORM
unset QT_QPA_EGLFS_DEPTH
unset QT_QPA_EGLFS_HIDECURSOR
unset QT_COMPOSITOR_NEGATE_INVERTED_Y

export LIBEXEC_PATH="/usr/libexec:/usr/lib/libexec:/usr/lib/libexec/kf5"
export QT_PLUGIN_PATH=${QT_PLUGIN_PATH+$QT_PLUGIN_PATH:}`qtpaths --plugin-dir`:/usr/lib/kde5/plugins

export QT_QPA_PLATFORM=wayland
export QT_QPA_PLATFORMTHEME=KDE
export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
export XDG_CURRENT_DESKTOP=KDE
export KSCREEN_BACKEND=QScreen

export KDE_FULL_SESSION=1
export KDE_SESSION_VERSION=5

exec /usr/bin/plasmashell -p org.kde.satellite.phone -n
