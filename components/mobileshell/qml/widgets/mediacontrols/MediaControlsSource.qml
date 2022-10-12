/*
 *  SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
 *  SPDX-FileCopyrightText: 2016 Kai Uwe Broulik <kde@privat.broulik.de>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.15

import org.kde.plasma.core 2.0 as PlasmaCore

PlasmaCore.DataSource {
    id: mpris2Source

    engine: "mpris2"
    connectedSources: sources
    
    readonly property string multiplexSource: "@multiplex"
    
    property var mprisSourcesModel: []
    
    readonly property bool hasPlayer: sources.length > 1

    function startOperation(src, op) {
        var service = serviceForSource(src)
        var operation = service.operationDescription(op)
        return service.startOperationCall(operation)
    }

    function goPrevious(source) {
        startOperation(source, "Previous");
    }
    function goNext(source) {
        startOperation(source, "Next");
    }
    function playPause(source) {
        startOperation(source, "PlayPause");
    }
    function isPlaying(source) {
        return data[source] ? data[source].PlaybackStatus === "Playing" : false;
    }
    function canControl(source) {
        return data[source] ? data[source].CanControl : false;
    }
    function canGoBack(source) {
        return data[source] ? data[source].CanGoPrevious : false;
    }
    function canGoNext(source) {
        return data[source] ? data[source].CanGoNext : false;
    }
    function track(source) {
        if (!data[source]) {
            return "";
        }
        const xesamTitle = data[source].Metadata["xesam:title"]
        if (xesamTitle) {
            return xesamTitle
        }
        // if no track title is given, print out the file name
        const xesamUrl = data[source].Metadata["xesam:url"] ? data[source].Metadata["xesam:url"].toString() : ""
        if (!xesamUrl) {
            return ""
        }
        const lastSlashPos = xesamUrl.lastIndexOf('/')
        if (lastSlashPos < 0) {
            return ""
        }
        const lastUrlPart = xesamUrl.substring(lastSlashPos + 1)
        return decodeURIComponent(lastUrlPart)
    }
    function artist(source) {
        return data[source] ? data[source].Metadata["xesam:artist"] || "" : "";
    }
    function albumArt(source) {
        return data[source] ? data[source].Metadata["mpris:artUrl"] || "" : "";
    }
    
    function updateMprisSourcesModel() {
        let model = [];
        
        let sources = mpris2Source.sources;
        for (let i = 0; i < sources.length; ++i) {
            let source = sources[i];
            if (source === mpris2Source.multiplexSource) {
                continue;
            }
            
            const playerData = mpris2Source.data[source];
            // source data is removed before its name is removed from the list
            if (!playerData) {
                continue;
            }

            model.push({
                'application': playerData["Identity"],
                'source': source,
                'desktopEntry': playerData["DesktopEntry"]
            });
        }
        
        mprisSourcesModel = model;
    }
    
    Component.onCompleted: {
        mpris2Source.serviceForSource("@multiplex").enableGlobalShortcuts()
        updateMprisSourcesModel()
    }
    
    onSourceAdded: updateMprisSourcesModel()
    onSourceRemoved: updateMprisSourcesModel();
}
