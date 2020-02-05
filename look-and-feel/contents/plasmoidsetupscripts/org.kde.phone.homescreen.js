applet.wallpaperPlugin = 'org.kde.image'
applet.writeConfig("AppOrder", ["org.kde.phone.dialer.desktop", "org.kde.mobile.angelfish.desktop", "org.kde.phone.calindori.desktop", "org.kde.mobile.camera.desktop"])
applet.writeConfig("Favorites", ["org.kde.phone.dialer.desktop", "org.kde.mobile.angelfish.desktop", "org.kde.phone.calindori.desktop", "org.kde.mobile.camera.desktop"])
containment.addWidget("org.kde.phone.krunner", 0, 0, screenGeometry(0).width, 20)
applet.reloadConfig()

