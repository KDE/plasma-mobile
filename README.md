<!--
- SPDX-FileCopyrightText: None 
- SPDX-License-Identifier: CC0-1.0
-->

# Plasma Mobile

This repository contains shell components for Plasma Mobile.

### Links
* Project page: https://invent.kde.org/plasma/plasma-mobile
* Documentation: https://invent.kde.org/plasma/plasma-mobile/-/wikis/home
* Issues relating to the shell: https://invent.kde.org/plasma/plasma-mobile/-/issues
* General Plasma Mobile issues: https://invent.kde.org/teams/plasma-mobile/issues/-/issues
* Development channel: https://matrix.to/#/#plasmamobile:matrix.org

### Locations
* [libmobileshell](libmobileshell) - shell component library (not guaranteed to be binary compatible between releases!)
* [containments](containments) - shell panels (homescreen, status bar, task panel)
* [homescreens](homescreens) - homescreen packages
* [kcms](kcms) - settings modules
* [look-and-feel](look-and-feel/contents) - Plasma look-and-feel packages (ex. lockscreen, logout, etc.)
* [quicksettings](quicksettings) - quick settings packages for the action drawer

### Test on a development machine

See the [documentation page](https://invent.kde.org/plasma/plasma-mobile/-/wikis/Building-and-Testing-Locally) for more details.

It is recommended to use `kdesrc-build` to build this from source. See [this page](https://community.kde.org/Get_Involved/development) in order to set it up.

Dependencies:
* KDE Frameworks 5 setup (plasma-framework and its dependencies)
* Plasma Nano

To start the phone homescreen in a window, run:
```
QT_QPA_PLATFORM=wayland dbus-run-session kwin_wayland --xwayland "plasmashell -p org.kde.plasma.phoneshell"
```
