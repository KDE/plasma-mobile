/*
*   SPDX-FileCopyrightText: 2021 Aleix Pol Gonzalez <aleixpol@kde.org>
 *
 *   SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.10

QtObject
{
    required property string text
    required property string icon
    property string settingsCommand
    property bool enabled: true

    default property var children: []
}
