
var desktopsArray = desktopsForActivity(currentActivity());
for (var j = 0; j < desktopsArray.length; j++) {
    desktopsArray[j].wallpaperPlugin = "org.kde.image";
}

var panel = new Panel("org.kde.phone.panel");
panel.addWidget("org.kde.phone.notifications");
panel.addWidget("org.kde.plasma.networkmanagement");
var battery = panel.addWidget("org.kde.plasma.battery");
battery.writeConfig("showPercentage", true);
battery.reloadConfig();
panel.addWidget("org.kde.plasma.volume");
panel.addWidget("org.kde.phone.activities");
panel.height = 1 * gridUnit;

var bottomPanel = new Panel("org.kde.phone.taskpanel");
bottomPanel.location = "bottom";

if (screenGeometry(bottomPanel.screen).height > screenGeometry(bottomPanel.screen).width)
    bottomPanel.height = 2 * gridUnit;
else
    bottomPanel.height = 1 * gridUnit;
