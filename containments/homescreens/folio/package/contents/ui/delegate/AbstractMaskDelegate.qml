// SPDX-FileCopyrightText: 2025 Micah Stanley <stanleymicah@proton.me>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick

import org.kde.private.mobile.homescreen.folio 1.0 as Folio

/**
 * Abstract mask template component.
 */

Item {
    id: maskComponent
    required property Item item
    required property Folio.HomeScreen folio

    visible: item ? item.visible : false

    implicitWidth: item ? item.implicitWidth : 0
    implicitHeight: item ? item.implicitHeight : 0
    width: item ? item.width : 0
    height: item ? item.height : 0

    x: item ? item.x : 0
    y: item ? item.y : 0
}
