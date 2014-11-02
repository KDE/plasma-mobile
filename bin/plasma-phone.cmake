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

@CMAKE_INSTALL_FULL_LIBEXECDIR@/ksyncdbusenv
@CMAKE_INSTALL_FULL_BINDIR@/kbuildsycoca5
LD_BIND_NOW=true @CMAKE_INSTALL_FULL_LIBEXECDIR_KF5@/start_kdeinit_wrapper
@CMAKE_INSTALL_FULL_BINDIR@/plasmashell -p org.kde.satellite.phone -n
