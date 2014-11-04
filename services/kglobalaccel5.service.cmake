#
# Copyright (C) 2014 Pier Luigi Fiorini <pierluigi.fiorini@gmail.com>
#
# Starts kglobalaccel5.
#

[Unit]
Description=kglobalaccel5

[Service]
Environment=DBUS_SESSION_BUS_ADDRESS=unix:path=%t/dbus/user_bus_socket
EnvironmentFile=-/var/lib/environment/plasma-phone/*.conf
ExecStart=@CMAKE_INSTALL_FULL_BINDIR@/kglobalaccel5
BusName=org.kde.kglobalaccel
