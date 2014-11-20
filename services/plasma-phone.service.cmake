#
# Copyright (C) 2014 Pier Luigi Fiorini <pierluigi.fiorini@gmail.com>
#
# Starts Plasma shell for phones.
#

[Unit]
Description=Plasma Phone
Requires=dbus.socket

[Service]
Environment=DBUS_SESSION_BUS_ADDRESS=unix:path=%t/dbus/user_bus_socket
Environment=PLASMA_PLATFORM=phone
Environment=QT_IM_MODULE=Maliit
ExecStart=@CMAKE_INSTALL_FULL_BINDIR@/plasma-phone
Restart=on-failure

[Install]
WantedBy=user-session.target
