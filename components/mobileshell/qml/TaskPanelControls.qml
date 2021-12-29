/*
 *  SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick 2.12
import org.kde.plasma.core 2.0 as PlasmaCore

pragma Singleton

/**
 * Provides access to the taskpanel plasmoid containment within the shell.
 */
QtObject {
    id: root
    property bool isPortrait
    property real panelHeight
    property real panelWidth
}

