
var desktopsArray = desktopsForActivity(currentActivity());
for (var j = 0; j < desktopsArray.length; j++) {
    desktopsArray[j].wallpaperPlugin = "org.kde.image";
    //desktopsArray[j].name = "Homescreen" + (j > 0 ? " " + j : "");
    desktopsArray[j].currentConfigGroup = ["Wallpaper",
                                           desktopsArray[j].wallpaperPlugin,
                                           "General"];
    desktopsArray[j].writeConfig("Image", "org.kde.plasma.phone.lockers");
}

desktopsArray[0].addWidget("org.kde.plasma.analogclock");

var panel = new Panel("org.kde.phone.panel");
panel.addWidget("org.kde.phone.notifications");
panel.addWidget("org.kde.plasma.networkmanagement");
var battery = panel.addWidget("org.kde.plasma.battery");
battery.writeConfig("showPercentage", true);
battery.reloadConfig();
panel.addWidget("org.kde.plasma.volume");
panel.addWidget("org.kde.phone.activities");
panel.height = 60;

var bottomPanel = new Panel("org.kde.phone.taskpanel");
bottomPanel.location = "bottom";

if (screenGeometry(bottomPanel.screen).height > screenGeometry(bottomPanel.screen).width)
    bottomPanel.height = 150;
else
    bottomPanel.height = 60;

if (activities().length < 2) {
    createActivity("Activity 2");
}
