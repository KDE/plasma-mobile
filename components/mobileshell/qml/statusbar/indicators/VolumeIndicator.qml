/*
    SPDX-FileCopyrightText: 2021 Devin Lin <eespidev@gmail.com>
    SPDX-FileCopyrightText: 2019 Aditya Mehra <Aix.m@outlook.com>
    SPDX-FileCopyrightText: 2014-2015 Harald Sitter <sitter@kde.org>

    SPDX-License-Identifier: LGPL-2.1-only OR LGPL-3.0-only OR LicenseRef-KDE-Accepted-LGPL
*/

import QtQuick
import QtQuick.Layouts

import org.kde.plasma.private.volume 0.1
import org.kde.kirigami as Kirigami

import org.kde.plasma.private.mobileshell as MobileShell

Kirigami.Icon {
    id: paIcon

    source: MobileShell.AudioInfo.icon

    visible: MobileShell.AudioInfo.isVisible
}
