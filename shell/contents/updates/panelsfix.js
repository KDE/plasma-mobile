let topFound = false
let bottomFound = false

for (let i in panels()) {
    print(panels()[i].type)
    if (panels()[i].type === "org.kde.phone.panel") {
        topFound = true;
    } else if (panels()[i].type === "org.kde.phone.taskpanel") {
        bottomFound = true;
    }
}

if (!topFound) {
    // keep widget list synced with the layout.js
    let topPanel = new Panel("org.kde.phone.panel")
    topPanel.addWidget("org.kde.plasma.notifications");
    topPanel.addWidget("org.kde.plasma.mediacontroller");
    topPanel.location = "top";
}
if (!bottomFound) {
    let bottomPanel = new Panel("org.kde.phone.taskpanel")
    bottomPanel.location = "bottom";
    bottomPanel.height = 2 * gridUnit;
}
