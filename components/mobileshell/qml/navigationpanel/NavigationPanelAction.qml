/*
 *  SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick 2.15

QtObject {
    property bool enabled
    property bool visible: true
    property string iconSource
    property real shrinkSize

    signal triggered()
}
