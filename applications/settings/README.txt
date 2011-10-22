

Application
- C++ app, that ...
- loads QML package which has the basic shell
- lists plugins for settings modules
- loads them into the shell dynamically




Email from Marco, explaining the basic architecture:

touchy settings UI architecture
From:   Marco Martin <notmart@gmail.com>
To: active@kde.org
Date:   Fri Oct 14 13:02:19 2011
Hi all,

one of the things is pretty clear we need for Active 2 is a centralized
settings ui, since systemsettings revealed to be so painful to use on a
touchscreen  that is now blacklisted (and 99% of its kcms wouldn't be useful)

so from a purely architectural (ui can be anything) point of view what i had
in mind was:

* the logic of the seetings of a particular thing is done in QObjects: a
setting will correspond to a qproperty

* to start them, let's start with the time and locale kcms, ripping all the ui
out of them, just leaving the config files read/write parts

* the time one reveals the need of specialized qobjects rather than just a
binding over kconfing: it sets the system time and uses policykit for that

* a qobject to write in generic config files could still be written, maybe it
could make possible for some of the config modules being written in pure QML

* configuration ui modules should be plasma packages
(/usr/share/kde4/apps/plasma/packages/*)

* the "outer shell" with tabs that can load different modules is a plasma
package as well

* the settings module logic is a kde c++ plugin, that has all the properties
for config options, plus a property that says the path of the root qml file
extracted from the package

* a kapplication loads the shell package, then, lists config plugins with
sycoca, puts them in a model to be visualized by the shell qml files

* after clicking on a config module icon, the c++ part loads the c++ plugin,
extracts the path of the qml file, slams the parsed qml instance in the main
screen of the config ui (that should be a PageStack component, probably)

is it clear? too complex? i still don't have completely clear if/how loading
config modules that are pure qml, suggestions (and ways to simplify it) are
welcome ;)

Cheers,
Marco Martin
_______________________________________________
Active mailing list
Active@kde.org
https://mail.kde.org/mailman/listinfo/active