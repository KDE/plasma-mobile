/*
 *  SPDX-FileCopyrightText: 2021 Devin Lin <espidev@gmail.com>
 *  SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>
 *  SPDX-FileCopyrightText: 2021 Tobias Fella <fella@posteo.de>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick 2.1

import org.kde.plasma.mm 1.0

QtObject {

    property string icon: "network-mobile-" + Math.floor(SignalIndicator.strength / 20) * 20

    property string label: !SignalIndicator.available ? ""
                         : SignalIndicator.simLocked ? i18n("SIM Locked") : SignalIndicator.name
}

