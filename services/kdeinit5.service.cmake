#
# Copyright (C) 2014 Pier Luigi Fiorini <pierluigi.fiorini@gmail.com>
#
# Starts kdeinit5.
#

[Unit]
Description=kdeinit5
Requires=dbus.socket

[Service]
Environment=DISPLAY:0
EnvironmentFile=-/var/lib/environment/plasma-phone/*.conf
ExecStart=@CMAKE_INSTALL_FULL_BINDIR@/kdeinit5 +kcminit_startup --no-fork
BusName=org.kde.klauncher5
