
var desktopsArray = desktopsForActivty(currentActivity());
for (var j = 0; j < desktopsArray.length; j++) {
    desktopsArray[j].wallpaperPlugin = "org.kde.image";
    //desktopsArray[j].name = "Homescreen" + (j > 0 ? " " + j : "");
    desktopsArray[j].currentConfigGroup = ["Wallpaper",
                                           desktopsArray[j].wallpaperPlugin,
                                           "General"];
    desktopsArray[j].writeConfig("Image", "org.kde.plasma.phone.lockers");
}

desktopsForActivity(id)[0].addWidget("org.kde.plasma.analogclock");

var panel = new Panel("org.kde.phone.panel");
panel.addWidget("org.kde.plasma.notifications");
panel.addWidget("org.kde.plasma.networkmanagement");
panel.addWidget("org.kde.plasma.phone.battery");
panel.addWidget("org.kde.plasma.volume");
panel.height = 60;

var bottomPanel = new Panel("org.kde.phone.taskpanel");
bottomPanel.location = "bottom";

if (screenGeometry(bottomPanel.screen).height > screenGeometry(bottomPanel.screen).width)
    bottomPanel.height = 150;
else
    bottomPanel.height = 60;

