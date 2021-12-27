/*
 *   SPDX-FileCopyrightText: 2015 Marco Martin <notmart@gmail.com>
 *
 *   SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.0
import QtQuick.Layouts 1.1

import org.kde.plasma.core 2.0 as PlasmaCore

PlasmaCore.IconItem {
    implicitWidth: PlasmaCore.Units.iconSizes.enormous
    implicitHeight: PlasmaCore.Units.iconSizes.enormous
    usesPlasmaTheme: false
    source: model.decoration
}
