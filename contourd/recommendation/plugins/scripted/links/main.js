index = 0;
config = self.getConfig();

function add(url, title, description, icon)
{
    if (config.BoolValue(url, false) == false) {
        self.addRecommendation(0.0, url, title, description, icon);
    }
}

add("http://www.kde.org/", "KDE community", "The people behind Plasma Active", "kde");
add("http://community.kde.org/Plasma/Active/Info#FAQ", "Usage manual", "How to use Plasma Active", "help-about");

self.activationRequested.connect(function fn(id, action) {
    self.openUrl(id);
    config.SetBoolValue(id, true);
});
