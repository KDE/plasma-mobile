// SPDX-FileCopyrightText: 2021-2023 Devin Lin <devin@kde.org>
// SPDX-FileCopyrightText: 2016 Kai Uwe Broulik <kde@privat.broulik.de>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick

import org.kde.plasma.private.mpris as Mpris
import org.kde.kitemmodels

QtObject {
    property var baseMpris2Model: Mpris.Mpris2Model {}

    property var mpris2Model: KSortFilterProxyModel {
        sourceModel: baseMpris2Model

        // filter and ignore first element, because it's the multiplexer (which will look like a duplicate source)
        filterRowCallback: function(source_row, source_parent) {
            return source_row !== 0;
        }
    }

    function startOperation(src, op) {
        var service = serviceForSource(src)
        var operation = service.operationDescription(op)
        return service.startOperationCall(operation)
    }

    function setIndex(index) {
        baseMpris2Model.currentIndex = index + 1; // account for first row being gone (multiplexer)
    }
    function goPrevious() {
        baseMpris2Model.currentPlayer.Previous();
    }
    function goNext() {
        baseMpris2Model.currentPlayer.Next();
    }
    function playPause() {
        baseMpris2Model.currentPlayer.PlayPause();
    }

    function updatePosition(): void {
        baseMpris2Model.currentPlayer.updatePosition();
    }
}
