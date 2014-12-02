#
# Copyright (C) 2014 Pier Luigi Fiorini <pierluigi.fiorini@gmail.com>
#
# Starts kdeinit5.
#

[Unit]
Description=kdeinit5
Requires=dbus.socket

[Service]
Environment=DBUS_SESSION_BUS_ADDRESS=unix:path=%t/dbus/user_bus_socket
EnvironmentFile=-/var/lib/environment/plasma-phone/*.conf
ExecStart=@CMAKE_INSTALL_FULL_BINDIR@/kdeinit5 +kcminit_startup --no-fork
BusName=org.kde.klauncher5
