var id = createActivity("Homescreen");
var desktopsArray = desktopsForActivity(id);
print("Reaaaaaally?????? " + desktopsArray.length);
for( var j = 0; j < desktopsArray.length; j++) {
    desktopsArray[j].wallpaperPlugin = 'org.kde.color';
    desktopsArray[j].currentConfigGroup = ["Wallpaper", "General"];
    print("currently at ... " + desktopsArray[j].currentConfigGroup);
    desktopsArray[j].writeConfig("Image", "org.kde.satellite.lockers");
}

