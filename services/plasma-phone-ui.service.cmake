#
# Copyright (C) 2014 Pier Luigi Fiorini <pierluigi.fiorini@gmail.com>
#
# Starts Plasma shell for phones.
#

[Unit]
Description=Plasma Phone UI
Requires=dbus.socket plasma-phone-compositor.service

[Service]
EnvironmentFile=-/var/lib/environment/plasma-phone/*.conf
ExecStart=@CMAKE_INSTALL_FULL_BINDIR@/plasma-phone
ExecStop=@CMAKE_INSTALL_FULL_BINDIR@/kquitapp5 plasmashell
Restart=on-failure
BusName=org.kde.plasmashell

[Install]
WantedBy=user-session.target
