var id = currentActivity();

if (id.length < 1) {
    id = createActivity("Homescreen")
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

