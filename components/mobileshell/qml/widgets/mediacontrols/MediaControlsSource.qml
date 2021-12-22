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

    readonly property string source: "@multiplex"
    readonly property var playerData: data[source]

    readonly property bool hasPlayer: sources.length > 1 && !!playerData
    readonly property string identity: hasPlayer ? playerData.Identity : ""
    readonly property bool playing: hasPlayer && playerData.PlaybackStatus === "Playing"
    readonly property bool canControl: hasPlayer && playerData.CanControl
    readonly property bool canGoBack: hasPlayer && playerData.CanGoPrevious
    readonly property bool canGoNext: hasPlayer && playerData.CanGoNext

    readonly property var currentMetadata: hasPlayer ? playerData.Metadata : ({})

    readonly property string track: {
        const xesamTitle = currentMetadata["xesam:title"]
        if (xesamTitle) {
            return xesamTitle
        }
        // if no track title is given, print out the file name
        const xesamUrl = currentMetadata["xesam:url"] ? currentMetadata["xesam:url"].toString() : ""
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
    readonly property string artist: currentMetadata["xesam:artist"] || ""
    readonly property string albumArt: currentMetadata["mpris:artUrl"] || ""

    engine: "mpris2"
    connectedSources: [source]

    function startOperation(op) {
        var service = serviceForSource(source)
        var operation = service.operationDescription(op)
        return service.startOperationCall(operation)
    }

    function goPrevious() {
        startOperation("Previous");
    }
    function goNext() {
        startOperation("Next");
    }
    function playPause(source) {
        startOperation("PlayPause");
    }
}
