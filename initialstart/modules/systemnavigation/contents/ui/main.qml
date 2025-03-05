// SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import org.kde.kirigami as Kirigami

import org.kde.kirigamiaddons.formcard as FormCard
import org.kde.plasma.mobileinitialstart.initialstart
import org.kde.plasma.private.mobileshell.shellsettingsplugin as ShellSettings

InitialStartModule {
    name: i18n("System Navigation")

    contentItem: Item {
        id: root

        readonly property real cardWidth: Math.min(Kirigami.Units.gridUnit * 30, root.width - Kirigami.Units.gridUnit * 2)

        ColumnLayout {
            anchors {
                fill: parent
                topMargin: Kirigami.Units.gridUnit
                bottomMargin: Kirigami.Units.gridUnit
            }

            width: root.width
            spacing: 0

            Label {
                Layout.leftMargin: Kirigami.Units.gridUnit
                Layout.rightMargin: Kirigami.Units.gridUnit
                Layout.alignment: Qt.AlignTop
                Layout.fillWidth: true

                wrapMode: Text.Wrap
                horizontalAlignment: Text.AlignHCenter
                text: i18n("Choose a method to navigate around the system.")
            }

            FormCard.FormCard {
                maximumWidth: root.cardWidth
                Layout.topMargin: Kirigami.Units.gridUnit
                Layout.fillWidth: true

                FormCard.FormRadioDelegate {
                    text: i18n("Gesture navigation")
                    description: i18n("Swipe up from the bottom to see running applications. Flick to go to the home screen.")
                    onClicked: {
                        if (checked && ShellSettings.Settings.navigationPanelEnabled) {
                            ShellSettings.Settings.navigationPanelEnabled = false;
                        }
                        checked = Qt.binding(function () { return !ShellSettings.Settings.navigationPanelEnabled; });
                    }

                    Binding on checked {
                        value: !ShellSettings.Settings.navigationPanelEnabled
                    }
                }
            }

            FormCard.FormCard {
                maximumWidth: root.cardWidth
                Layout.topMargin: Kirigami.Units.largeSpacing
                Layout.fillWidth: true

                FormCard.FormRadioDelegate {
                    text: i18n("Button navigation")
                    description: i18n("Use buttons on a navigation bar to navigate the system.")
                    onClicked: {
                        if (checked && !ShellSettings.Settings.navigationPanelEnabled) {
                            ShellSettings.Settings.navigationPanelEnabled = true;
                        }
                        checked = Qt.binding(function () { return ShellSettings.Settings.navigationPanelEnabled; });
                    }

                    Binding on checked {
                        value: ShellSettings.Settings.navigationPanelEnabled
                    }
                }
            }

            Label {
                Layout.topMargin: Kirigami.Units.gridUnit
                Layout.leftMargin: Kirigami.Units.gridUnit
                Layout.rightMargin: Kirigami.Units.gridUnit
                Layout.fillWidth: true

                wrapMode: Text.Wrap
                horizontalAlignment: Text.AlignHCenter
                text: i18n("This can later be changed in the settings.")
            }

            Item {
                Layout.fillHeight: true
            }
        }
    }
}
