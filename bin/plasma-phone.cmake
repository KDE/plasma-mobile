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

unset EGL_PLATFORM
unset QT_QPA_PLATFORM
unset QT_QPA_EGLFS_DEPTH
unset QT_QPA_EGLFS_HIDECURSOR
unset QT_COMPOSITOR_NEGATE_INVERTED_Y

export QT_QPA_PLATFORM=wayland
export QT_QPA_PLATFORMTHEME=KDE
export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
export QT_IM_MODULE=maliit
export XDG_CURRENT_DESKTOP=KDE
export KSCREEN_BACKEND=QScreen

export KDE_FULL_SESSION=1
export KDE_SESSION_VERSION=5
export PLASMA_PLATFORM=phone
export QT_QUICK_CONTROLS_STYLE=Plasma

export GRID_UNIT_PX=25
export FORCE_RIL_NUM_MODEMS=1

# upstart user session has useful bits like mtp-server
init --user &

sleep 5

paplay /usr/share/sounds/sitter/brmm.ogg &

exec /usr/bin/plasmashell -p org.kde.plasma.phone 2>/tmp/plasmashell_logs
dbus-send --session --dest=org.freedesktop.DBus /org/freedesktop/DBus org.freedesktop.DBus.StartServiceByName string:org.freedesktop.Telepathy.MissionControl5 uint32:0
