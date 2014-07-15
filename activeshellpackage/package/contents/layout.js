var panel = new Panel("org.kde.plasma.activepanel")
panel.screen = 0
panel.location = 'top'

panel.addWidget("org.kde.plasma.devicenotifier")
panel.addWidget("org.kde.plasma.notifications")
panel.addWidget("org.kde.plasma.networkmanagement")
panel.addWidget("org.kde.plasma.digitalclock")

for (var i = 0; i < screenCount; ++i) {
    var id = createActivity("Desktop");
    var desktopsArray = desktopsForActivity(id);
    print(desktopsArray.length);
    for( var j = 0; j < desktopsArray.length; j++) {
        desktopsArray[j].wallpaperPlugin = 'org.kde.image';
        //var clock = desktopsArray[j].addWidget("org.kde.plasma.analogclock");
    }
}
