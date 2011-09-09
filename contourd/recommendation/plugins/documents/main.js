index = 0;

self.addRecommendation(1.0, "http://www.kde.org", "KDE homepage", "This is the homepage of an uber-awesome community", "kde");
self.addRecommendation(1.6, "http://plasma.kde.org", "Plasma homepage", "This is the plasma home page", "plasma");
self.addRecommendation(1.0, "http://www.wikipedia.org", "Wikipedia", "The biggest encyclopedia in the world", "konqueror");

// self.getTimer(1000).timeout.connect(function SignalHandler(params) {
//     self.addRecommendation(index, "http://www.wikipedia.org", "Wikipedia" + index, "The biggest encyclopedia in the world", "konqueror");
//     index ++;
// });

self.activationRequested.connect(function fn(id, action) {
    self.openUrl(id);
});
