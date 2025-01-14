/*
    SPDX-FileCopyrightText: 2019 Jonah Brüchert <jbb@kaidan.im>

    SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
*/

import QtQuick.Layouts 1.2
import QtQuick 2.7
import QtQuick.Controls 2.2 as Controls

import org.kde.kcmutils as KCM
import org.kde.kirigami 2.10 as Kirigami
import org.kde.kirigamiaddons.formcard 1 as FormCard

KCM.SimpleKCM {
    title: i18n("System Information")

    leftPadding: 0
    rightPadding: 0
    topPadding: 0
    bottomPadding: Kirigami.Units.gridUnit

    actions: [
        Kirigami.Action {
            icon.name: "edit-copy"
            text: i18nc("@action:button", "Copy")
            onTriggered: kcm.copyInfoToClipboard()
        }
    ]

    ColumnLayout {
        spacing: 0

        Kirigami.Icon {
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: Kirigami.Units.gridUnit
            Layout.bottomMargin: Kirigami.Units.gridUnit
            implicitWidth: Kirigami.Units.iconSizes.huge
            implicitHeight: width
            source: kcm.distroInfo.logo ? kcm.distroInfo.logo : "kde"
        }

        FormCard.FormCard {
            Layout.fillWidth: true

            FormCard.FormTextDelegate {
                text: i18n("Operating System")
                description: kcm.distroInfo.name
            }

            FormCard.FormDelegateSeparator {}

            FormCard.FormButtonDelegate {
                text: i18n("Webpage")
                description: kcm.distroInfo.homeUrl
                onClicked: {
                    Qt.openUrlExternally(kcm.distroInfo.homeUrl)
                }
            }
        }

        FormCard.FormHeader {
            title: i18nc("@title:group", "Software")
        }

        FormCard.FormCard {
            FormCard.FormTextDelegate {
                text: i18n("KDE Plasma Version")
                description: kcm.softwareInfo.plasmaVersion
            }

            FormCard.FormDelegateSeparator {}

            FormCard.FormTextDelegate {
                text: i18n("KDE Frameworks Version")
                description: kcm.softwareInfo.frameworksVersion
            }

            FormCard.FormDelegateSeparator {}

            FormCard.FormTextDelegate {
                text: i18n("Qt Version")
                description: kcm.softwareInfo.qtVersion
            }

            FormCard.FormDelegateSeparator {}

            FormCard.FormTextDelegate {
                text: i18n("Kernel Version")
                description: kcm.softwareInfo.kernelRelease
            }

            FormCard.FormDelegateSeparator {}

            FormCard.FormTextDelegate {
                text: i18n("OS Type")
                description: i18nc("@label %1 is the CPU bit width (e.g. 32 or 64)", "%1-bit", kcm.softwareInfo.osType)
            }
        }

        FormCard.FormHeader {
            title: i18nc("@title:group", "Hardware")
        }

        FormCard.FormCard {
            FormCard.FormTextDelegate {
                text: i18np("Processor", "Processors", kcm.hardwareInfo.processorCount);
                description: kcm.hardwareInfo.processors
            }

            FormCard.FormDelegateSeparator {}

            FormCard.FormTextDelegate {
                text: i18n("Memory")
                description: {
                    if (kcm.hardwareInfo.memory !== "0 B") {
                        return i18nc("@label %1 is the formatted amount of system memory (e.g. 7,7 GiB)",
                            "%1 of RAM", kcm.hardwareInfo.memory)
                    } else {
                        return i18nc("Unknown amount of RAM", "Unknown")
                    }
                }
            }
        }

        FormCard.FormHeader {
            visible: kcm.vendorInfoTitle !== ""
            title: kcm.vendorInfoTitle
        }

        FormCard.FormCard {
            visible: kcm.vendorInfoTitle !== ""
            Repeater {
                model: kcm.vendorInfo
                ColumnLayout {
                    id: delegate

                    required property var modelData

                    spacing: 0

                    FormCard.FormTextDelegate {
                        text: delegate.modelData.Key
                        description: delegate.modelData.Value
                    }
                    FormCard.FormDelegateSeparator {}
                }
            }
        }
    }
}
