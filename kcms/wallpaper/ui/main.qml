// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2

import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM
import org.kde.kirigamiaddons.formcard 1.0 as FormCard
import org.kde.plasma.private.mobileshell.shellsettingsplugin as ShellSettings
import org.kde.plasma.private.mobileshell.wallpaperimageplugin as WallpaperImagePlugin
import org.kde.newstuff as NewStuff

KCM.SimpleKCM {
    id: root

    title: i18n("Wallpaper")

    topPadding: Kirigami.Units.gridUnit
    bottomPadding: Kirigami.Units.gridUnit
    leftPadding: 0
    rightPadding: 0

    ColumnLayout {

        FormCard.FormCard {
            id: generalCard

            FormCard.FormButtonDelegate {
                id: homescreenWallpaper
                text: i18n("Change homescreen wallpaper")
                onClicked: {
                    if (!homescreenPage.active) {
                        homescreenPage.active = true;
                    }
                    kcm.push(homescreenPage.item);
                }
            }

            FormCard.FormDelegateSeparator { above: homescreenWallpaper; below: lockscreenWallpaper }

            FormCard.FormButtonDelegate {
                id: lockscreenWallpaper
                text: i18n("Change lockscreen wallpaper")
                onClicked: {
                    if (!lockscreenPage.active) {
                        lockscreenPage.active = true;
                    }
                    kcm.push(lockscreenPage.item);
                }
            }
        }

        Loader {
            id: homescreenPage
            active: false
            sourceComponent: WallpaperConfigPage {
                title: i18n("Homescreen Wallpaper")
                
                currentWallpaperPlugin: WallpaperImagePlugin.WallpaperPlugin.homescreenWallpaperPlugin
                currentWallpaperPluginSource: WallpaperImagePlugin.WallpaperPlugin.homescreenWallpaperPluginSource
                wallpaperPluginConfig: WallpaperImagePlugin.WallpaperPlugin.homescreenConfiguration

                onRequestSave: {
                    WallpaperImagePlugin.WallpaperPlugin.saveHomescreenSettings();
                }

                onRequestChangeWallpaperPlugin: (name) => {
                    WallpaperImagePlugin.WallpaperPlugin.setHomescreenWallpaperPlugin(name);
                }
            }
        }

        Loader {
            id: lockscreenPage
            active: false
            sourceComponent: WallpaperConfigPage {
                title: i18n("Lockscreen Wallpaper")

                currentWallpaperPlugin: WallpaperImagePlugin.WallpaperPlugin.lockscreenWallpaperPlugin
                currentWallpaperPluginSource: WallpaperImagePlugin.WallpaperPlugin.lockscreenWallpaperPluginSource
                wallpaperPluginConfig: WallpaperImagePlugin.WallpaperPlugin.lockscreenConfiguration

                onRequestSave: {
                    WallpaperImagePlugin.WallpaperPlugin.saveLockscreenSettings();
                }

                onRequestChangeWallpaperPlugin: (name) => {
                    WallpaperImagePlugin.WallpaperPlugin.setLockscreenWallpaperPlugin(name);
                }
            }
        }
    }
}
