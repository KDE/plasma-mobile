plasma-phone-components
=======================

UI components for Plasma Phone

Test on a development machine
=======================

Dependencies:
* KDE Frameworks 5 setup (plasma-framework and its dependencies)
* oFono https://git.kernel.org/cgit/network/ofono/ofono.git
* libqofono https://github.com/nemomobile/libqofono
* ofono-phonesim https://git.kernel.org/cgit/network/ofono/phonesim.git/

If you want to test some part specific to telephony, set up ofono-phonesim according to https://docs.plasma-mobile.org/Ofono.html

To start the phone homescreen in a window, run:
```
QT_QPA_PLATFORM=wayland dbus-run-session kwin_wayland --xwayland "plasmashell -p org.kde.plasma.phone"
```
