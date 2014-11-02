#
# Copyright (C) 2014 Pier Luigi Fiorini <pierluigi.fiorini@gmail.com>
#
# Starts kded5.
#

[Unit]
Description=kded5
Requires=kdeinit5.service

[Service]
EnvironmentFile=-/var/lib/environment/plasma-phone/*.conf
ExecStart=@CMAKE_INSTALL_FULL_BINDIR@/kded5
BusName=org.kde.kded5
