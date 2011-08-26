for (var i in panelIds) {
    var panel = panelById(panelIds[i]);
    for (var j in panel.widgetIds) {
        var widget = panel.widgetById(panel.widgetIds[j]);
        if (widget.type == "digital-clock") {
            widget.currentConfigGroup = new Array();
            widget.writeConfig('showEvents', 'false');
            widget.reloadConfig();
        }
    }
}
