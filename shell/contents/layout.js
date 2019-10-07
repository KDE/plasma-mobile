
var desktopsArray = desktopsForActivity(currentActivity());
for (var j = 0; j < desktopsArray.length; j++) {
    desktopsArray[j].wallpaperPlugin = "org.kde.image";
}

var panel = new Panel("org.kde.phone.panel");
panel.addWidget("org.kde.phone.notifications");
panel.addWidget("org.kde.plasma.mediacontroller");
panel.addWidget("org.kde.plasma.devicenotifier");
panel.height = 1 * gridUnit;

var bottomPanel = new Panel("org.kde.phone.taskpanel");
bottomPanel.location = "bottom";

if (screenGeometry(bottomPanel.screen).height > screenGeometry(bottomPanel.screen).width)
    bottomPanel.height = 2 * gridUnit;
else
    bottomPanel.height = 1 * gridUnit;
