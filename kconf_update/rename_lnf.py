#!/usr/bin/env python3
import fileinput

for line in fileinput.input():
    if line.startswith("LookAndFeelPackage="):
        print ("# CHANGE LookAndFeelPackage")
        line = line.replace("org.kde.plasma.phone", "org.kde.plasma.phonelnf")
        print (line.strip())
