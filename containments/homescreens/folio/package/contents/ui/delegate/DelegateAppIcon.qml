// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import QtQuick.Effects

import org.kde.kirigami 2.20 as Kirigami

import org.kde.private.mobile.homescreen.folio 1.0 as Folio

Kirigami.Icon {
    id: root
    property Folio.HomeScreen folio

    height: folio.FolioSettings.delegateIconSize
    width: folio.FolioSettings.delegateIconSize

    roundToIconSize: false
    animated: false
}
