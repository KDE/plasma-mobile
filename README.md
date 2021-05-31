# plasma-phone-components

UI components for Plasma Mobile.

Contains components such as:
* Shell panels ([task panel](containments/taskpanel), and [top panel](containments/panel))
* [Homescreen](containments/homescreen)
* [Logout menu](look-and-feel/contents/logout)
* [Lockscreen theme](look-and-feel/contents/lockscreen)
* [Search applet](applets/krunner)

## Links
* Project page: https://invent.kde.org/plasma/plasma-phone-components
* Issues relating to the shell: https://invent.kde.org/plasma-mobile/plasma-phone-components/-/issues
* General Plasma Mobile issues: https://invent.kde.org/teams/plasma-mobile/issues/-/issues
* Development channel: https://matrix.to/#/#plasmamobile:matrix.org

## Test on a development machine

Dependencies:
* KDE Frameworks 5 setup (plasma-framework and its dependencies)
* oFono https://git.kernel.org/cgit/network/ofono/ofono.git
* libqofono https://git.merproject.org/mer-core/libqofono
* ofono-phonesim https://git.kernel.org/cgit/network/ofono/phonesim.git/

If you want to test some part specific to telephony, set up ofono-phonesim according to https://docs.plasma-mobile.org/Ofono.html

To start the phone homescreen in a window, run:
```
QT_QPA_PLATFORM=wayland dbus-run-session kwin_wayland --xwayland "plasmashell -p org.kde.plasma.phoneshell"
```
