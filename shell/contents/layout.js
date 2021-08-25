var desktopsArray = desktopsForActivity(currentActivity());
for (var j = 0; j < desktopsArray.length; j++) {
    desktopsArray[j].wallpaperPlugin = "org.kde.image";
}
desktopsArray[0].addWidget("org.kde.phone.krunner", 0, 0, screenGeometry(0).width, 20)
// keep this list in sync with shell/contents/updates/panelsfix.js
var panel = new Panel("org.kde.phone.panel");
panel.addWidget("org.kde.plasma.notifications");
panel.addWidget("org.kde.plasma.mediacontroller");
panel.height = 1 * gridUnit;

var bottomPanel = new Panel("org.kde.phone.taskpanel")
