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
    let topPanel = new Panel("org.kde.phone.panel")
    topPanel.location = "Top";
}
if (!bottomFound) {
    let topPanel = new Panel("org.kde.phone.taskpanel")
    topPanel.location = "Bottom";
}
