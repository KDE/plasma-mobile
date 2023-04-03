// SPDX-FileCopyrightText: 2019-2020 Marco Martin <mart@kde.org>
// SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

applet.wallpaperPlugin = 'org.kde.image'
applet.writeConfig("AppOrder", ["org.kde.phone.dialer.desktop", "org.kde.spacebar.desktop", "org.kde.angelfish.desktop"])
applet.writeConfig("Favorites", ["org.kde.phone.dialer.desktop", "org.kde.spacebar.desktop", "org.kde.angelfish.desktop"])
applet.reloadConfig()

