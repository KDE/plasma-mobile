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

exec dbus-run-session -- /usr/bin/plasmashell -p org.kde.satellite.phone -n
