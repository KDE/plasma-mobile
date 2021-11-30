var desktopsArray = desktopsForActivity(currentActivity());
for (var j = 0; j < desktopsArray.length; j++) {
    desktopsArray[j].wallpaperPlugin = "org.kde.image";
}

// keep this list in sync with shell/contents/updates/panelsfix.js
var panel = new Panel("org.kde.phone.panel");
panel.location = "top";
panel.addWidget("org.kde.plasma.notifications");
panel.addWidget("org.kde.plasma.mediacontroller");
panel.height = 1.25 * gridUnit; // HACK: supposed to be gridUnit + smallSpacing, but it doesn't seem to give the correct number

var bottomPanel = new Panel("org.kde.phone.taskpanel")
bottomPanel.location = "bottom";
bottomPanel.height = 2 * gridUnit;
