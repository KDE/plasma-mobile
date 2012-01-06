#!/usr/bin/python

# This is a quick and dirty script to monitor when connman
# connects to a network, or disconnects from it.
# On those events, it passes the info to the locationmanager daemon
# via the dummy network notifier

import gobject
import dbus
import dbus.mainloop.glib

dbus.mainloop.glib.DBusGMainLoop(set_as_default=True)

bus = dbus.SystemBus()

# Getting the main connman object
main_obj = bus.get_object('net.connman', '/')
props = main_obj.GetProperties(dbus_interface='net.connman.Manager')

def notify_locationmanager(networkName):
    global bus

    locationmanager_obj = bus.get_object('org.kde.LocationManager', '/ConnmanInterface')
    props = main_obj.setWifiName(networkName)


def main_obj_propchg(key, value):
    global bus
    global main_obj

    if key == "State":
        if value == "online" :
            # searching for active wifi info
            services = main_obj.GetServices(dbus_interface='net.connman.Manager')
            for service in services:
                for part in service:
                    if isinstance(part, dbus.Dictionary):
                        if (part["State"] == "ready"):
                            print("CONNECTED TO:", part["Name"])
                            notify_locationmanager(part["Name"])
                            return

        # we are offline
        print("OFFLINE")
        notify_locationmanager("")


bus.add_signal_receiver(main_obj_propchg, dbus_interface = "net.connman.Manager", signal_name = "PropertyChanged")

loop = gobject.MainLoop()
loop.run()
