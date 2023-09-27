// SPDX-FileCopyrightText: 2021-2023 Devin Lin <devin@kde.org>
// SPDX-FileCopyrightText: 2016 Kai Uwe Broulik <kde@privat.broulik.de>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick

import org.kde.plasma.private.mpris as Mpris

QtObject {
    property var mpris2Model: Mpris.Mpris2Model {}

    readonly property string multiplexSource: "@multiplex"

    property var mprisSourcesModel: []

    function startOperation(src, op) {
        var service = serviceForSource(src)
        var operation = service.operationDescription(op)
        return service.startOperationCall(operation)
    }

    function setIndex(index) {
        mpris2Model.currentIndex = index;
    }
    function goPrevious() {
        mpris2Model.currentPlayer.Previous();
    }
    function goNext() {
        mpris2Model.currentPlayer.Next();
    }
    function playPause() {
        mpris2Model.currentPlayer.PlayPause();
    }
}
