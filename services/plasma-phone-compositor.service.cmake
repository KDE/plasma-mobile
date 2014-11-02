#
# Copyright (C) 2014 Pier Luigi Fiorini <pierluigi.fiorini@gmail.com>
#
# Starts Green Island with the phone compositor plugin.
#

[Unit]
Description=Green Island
Requires=dbus.socket pre-user-session.target
After=pre-user-session.target
Conflicts=maui-bootsplash.service

[Service]
Type=notify
EnvironmentFile=-/var/lib/environment/compositor/*.conf
EnvironmentFile=-/var/lib/environment/greenisland/*.conf
ExecStart=@CMAKE_INSTALL_FULL_BINDIR@/greenisland $LIPSTICK_OPTIONS -p org.kde.satellite.compositor.phone
Restart=on-failure

[Install]
WantedBy=user-session.target
