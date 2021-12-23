<!--
- SPDX-FileCopyrightText: None 
- SPDX-License-Identifier: CC0-1.0
-->

# plasma-phone-components

UI components for Plasma Mobile.

Locations:
* [applets](applets) - plasmoids
* [components/mobileshell](components/mobileshell) - shell component library
* [containments](containments) - shell panels (homescreen, status bar, task panel)
* [look-and-feel](look-and-feel/contents) - Plasma look-and-feel packages (ex. lockscreen, logout, etc.)
* [quicksettings](quicksettings) - quick settings packages for the action drawer

## Links
* Project page: https://invent.kde.org/plasma/plasma-phone-components
* Issues relating to the shell: https://invent.kde.org/plasma-mobile/plasma-phone-components/-/issues
* General Plasma Mobile issues: https://invent.kde.org/teams/plasma-mobile/issues/-/issues
* Development channel: https://matrix.to/#/#plasmamobile:matrix.org

## Test on a development machine

It is recommended to use `kdesrc-build` to build this from source. See [this page](https://community.kde.org/Get_Involved/development) in order to set it up.

Dependencies:
* KDE Frameworks 5 setup (plasma-framework and its dependencies)
* Plasma Nano

To start the phone homescreen in a window, run:
```
QT_QPA_PLATFORM=wayland dbus-run-session kwin_wayland --xwayland "plasmashell -p org.kde.plasma.phoneshell"
```
