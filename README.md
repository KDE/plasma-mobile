plasma-phone-components
=======================

UI components for Plasma Phone

Test on a development machine
=======================

Dependencies:
* KDE Frameworks 5 setup (plasma-framework and its dependencies)
* oFono https://git.kernel.org/cgit/network/ofono/ofono.git
* voicecall https://github.com/nemomobile/voicecall
* libqofono https://github.com/nemomobile/libqofono
* ofono-phonesim https://git.kernel.org/cgit/network/ofono/phonesim.git/
* qml contextkit plugin https://github.com/nemomobile/nemo-qml-plugin-contextkit FIXME: ContextKit is deprecated, battery status should be ported to something else

Phonesim will add a fake phone modem, that can be controlled via a Qt based user interface from
which it will be possible to test various aspects of the phone UI: making calls, receiving, signal strength,
send SMS and so on. It will not generate any real call, but only make the UI think a SIM is working and that
a phone call is in progress.

A tutorial how to start phonesim on a desktop system can be found here:
http://comments.gmane.org/gmane.comp.handhelds.ofono/12178

* edit /etc/ofono/phonesim.conf, uncomment everything so that it looks like
 [phonesim]

 Driver=phonesim
 
 Address=127.0.0.1
 
 Port=12345


* start ofonod as root
* start phonesim
  phonesim -p 12345  -gui  /usr/share/phonesim/default.xml
* from the oFono *source* directory, call /test/enable-modem to bring the modem up, the control UI should come up
* start plasma with plasmashell -w -p org.kde.satellite.phone to start the phone homescreen in a window

Note that the oFono/phonesim part is necessary only if it's needed to test some part specific to telephony
