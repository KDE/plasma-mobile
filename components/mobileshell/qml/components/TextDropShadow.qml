// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick.Effects

// Standard drop shadow for text in the shell.
// Use a drop shadow when text needs to be contrasted over a background.

MultiEffect {
    shadowEnabled: true
    shadowVerticalOffset: 1
    blurMax: 8
    shadowOpacity: 0.6
}
