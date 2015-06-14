var id = currentActivity();

if (id.length < 1) {
    id = createActivity("Homescreen", "org.kde.phone.homescreen")
}

var desktopsArray = desktopsForActivity(id);
for (var j = 0; j < desktopsArray.length; j++) {
    desktopsArray[j].wallpaperPlugin = "org.kde.image";
    //desktopsArray[j].name = "Homescreen" + (j > 0 ? " " + j : "");
    desktopsArray[j].currentConfigGroup = ["Wallpaper",
                                           desktopsArray[j].wallpaperPlugin,
                                           "General"];
    desktopsArray[j].writeConfig("Image", "org.kde.satellite.lockers");
}

desktopsForActivity(id)[0].addWidget("org.kde.phone.notifications");

var panel = new Panel("org.kde.phone.panel");
panel.addWidget("org.kde.plasma.networkmanagement");
panel.addWidget("org.kde.plasma.phone.battery");
panel.height = 60;

var bottomPanel = new Panel("org.kde.phone.taskpanel");
bottomPanel.location = "bottom";
bottomPanel.height = 150;

