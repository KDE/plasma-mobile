#
# Copyright (C) 2014 Pier Luigi Fiorini <pierluigi.fiorini@gmail.com>
#
# Starts Plasma shell for phones.
#

[Unit]
Description=Plasma Phone UI
Requires=dbus.socket plasma-phone-compositor.service
After=plasma-phone-compositor.service

[Service]
Environment=DBUS_SESSION_BUS_ADDRESS=unix:path=%t/dbus/user_bus_socket
EnvironmentFile=-/var/lib/environment/plasma-phone/*.conf
ExecStart=@CMAKE_INSTALL_FULL_BINDIR@/plasmashell -p org.kde.plasma.phone -n
ExecStop=@CMAKE_INSTALL_FULL_BINDIR@/kquitapp5 plasmashell
Restart=on-failure
BusName=org.kde.plasmashell

[Install]
WantedBy=user-session.target
