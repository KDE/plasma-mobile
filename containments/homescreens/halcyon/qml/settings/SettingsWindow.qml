// SPDX-FileCopyrightText: 2023-2025 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick.Controls as QQC2

import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami
import org.kde.kirigamiaddons.formcard as FormCard

Window {
    id: root

    flags: Qt.FramelessWindowHint
    color: 'transparent'

    onVisibleChanged: {
        if (visible) {
            opacityAnim.to = 1;
            opacityAnim.restart();
        }
    }

    onClosing: (close) => {
        if (applicationItem.opacity !== 0) {
            close.accepted = false;
            opacityAnim.to = 0;
            opacityAnim.restart();
        }
    }

    signal requestConfigureMenu()

    Kirigami.ApplicationItem {
        id: applicationItem
        anchors.fill: parent

        opacity: 0

        NumberAnimation on opacity {
            id: opacityAnim
            duration: Kirigami.Units.longDuration
            easing.type: Easing.OutCubic
            onFinished: {
                if (applicationItem.opacity === 0) {
                    root.close();
                }
            }
        }

        scale: 0.7 + 0.3 * applicationItem.opacity

        pageStack.globalToolBar.style: Kirigami.ApplicationHeaderStyle.ToolBar
        pageStack.globalToolBar.showNavigationButtons: Kirigami.ApplicationHeaderStyle.NoNavigationButtons;

        pageStack.initialPage: Kirigami.ScrollablePage {
            id: page
            opacity: applicationItem.opacity

            titleDelegate: RowLayout {
                QQC2.ToolButton {
                    Layout.leftMargin: -Kirigami.Units.gridUnit + Kirigami.Units.smallSpacing
                    icon.name: "arrow-left"
                    onClicked: root.close()
                }

                Kirigami.Heading {
                    level: 1
                    text: page.title
                }
            }

            title: i18n("Homescreen Settings")

            topPadding: 0
            bottomPadding: 0
            leftPadding: 0
            rightPadding: 0

            ColumnLayout {

                FormCard.FormHeader {
                    title: i18n("Homescreen")
                }

                FormCard.FormCard {
                    FormCard.FormComboBoxDelegate {
                        id: wallpaperBlurCombobox
                        text: i18n("Wallpaper blur effect")

                        model: [
                            {"name": i18nc("Wallpaper blur effect", "None"), "value": 0},
                            {"name": i18nc("Wallpaper blur effect", "Simple"), "value": 1},
                            {"name": i18nc("Wallpaper blur effect", "Full"), "value": 2}
                        ]

                        textRole: "name"
                        valueRole: "value"

                        Component.onCompleted: {
                            currentIndex = indexOfValue(Plasmoid.settings.wallpaperBlurEffect);
                            dialog.parent = root;
                        }
                        onCurrentValueChanged: Plasmoid.settings.wallpaperBlurEffect = currentValue
                    }

                    FormCard.FormDelegateSeparator { above: wallpaperBlurCombobox; below: doubleTapToSleepSwitch }

                    FormCard.FormSwitchDelegate {
                        id: doubleTapToSleepSwitch
                        text: i18n("Double tap to lock device")
                        checked: Plasmoid.settings.doubleTapToLock
                        onCheckedChanged: {
                            if (checked != Plasmoid.settings.doubleTapToLock) {
                                Plasmoid.settings.doubleTapToLock = checked;
                            }
                        }
                    }
                }

                FormCard.FormCard {
                    Layout.topMargin: Kirigami.Units.largeSpacing
                    Layout.bottomMargin: Kirigami.Units.gridUnit

                    FormCard.FormButtonDelegate {
                        id: containmentSettings
                        text: i18nc("@action:button", "Switch between homescreens and more wallpaper options")
                        icon.name: 'settings-configure'
                        onClicked: root.requestConfigureMenu()
                    }
                }
            }
        }
    }
}
