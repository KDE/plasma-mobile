#!/bin/sh
# SPDX-FileCopyrightText: 2019 Aleix Pol Gonzalez <aleixpol@kde.org>
#
# SPDX-License-Identifier: GPL-2.0-or-later

. "@CMAKE_INSTALL_FULL_LIBEXECDIR@/plasma-dev-prefix.sh"

# This is a bit of a hack done because systemd starts in pam, and we only set our dev paths after all that is complete
# This copies everything into a transient runtime directory that systemd reads and reloads the units

if [ -n "$XDG_RUNTIME_DIR" ]; then
    mkdir -p "$XDG_RUNTIME_DIR/systemd/user.control"
    cp -r @KDE_INSTALL_FULL_SYSTEMDUSERUNITDIR@/* "$XDG_RUNTIME_DIR"/systemd/user.control
    systemctl --user daemon-reload
fi


startplasmamobile "$@"

