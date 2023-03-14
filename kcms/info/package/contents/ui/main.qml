/*
    SPDX-FileCopyrightText: 2019 Jonah Brüchert <jbb@kaidan.im>

    SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
*/

import QtQuick.Layouts 1.2
import QtQuick 2.7
import QtQuick.Controls 2.2 as Controls

import org.kde.kcm 1.2 as KCM
import org.kde.kirigami 2.10 as Kirigami
import org.kde.kirigamiaddons.labs.mobileform 0.1 as MobileForm

KCM.SimpleKCM {
    title: i18n("System Information")

    leftPadding: 0
    rightPadding: 0
    Kirigami.Theme.colorSet: Kirigami.Theme.Window

    ColumnLayout {
        width: parent.width
        spacing: 0

        Kirigami.Icon {
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: Kirigami.Units.gridUnit
            Layout.bottomMargin: Kirigami.Units.gridUnit
            implicitWidth: Kirigami.Units.iconSizes.huge
            implicitHeight: width
            source: kcm.distroInfo.logo ? kcm.distroInfo.logo : "kde"
        }
        
        MobileForm.FormCard {
            Layout.fillWidth: true
            
            contentItem: ColumnLayout {
                spacing: 0
                
                MobileForm.FormTextDelegate {
                    text: i18n("Operating System")
                    description: kcm.distroInfo.name
                }
                
                MobileForm.FormDelegateSeparator {}
                
                MobileForm.FormButtonDelegate {
                    text: i18n("Webpage")
                    description: kcm.distroInfo.homeUrl
                    onClicked: {
                        Qt.openUrlExternally(kcm.distroInfo.homeUrl)
                    }
                }
            }
        }
        
        MobileForm.FormCard {
            Layout.fillWidth: true
            Layout.topMargin: Kirigami.Units.largeSpacing
            
            contentItem: ColumnLayout {
                spacing: 0
                
                MobileForm.FormCardHeader {
                    title: "Software"
                }
                
                MobileForm.FormTextDelegate {
                    text: i18n("KDE Plasma Version")
                    description: kcm.softwareInfo.plasmaVersion
                }
                
                MobileForm.FormDelegateSeparator {}
                
                MobileForm.FormTextDelegate {
                    text: i18n("KDE Frameworks Version")
                    description: kcm.softwareInfo.frameworksVersion
                }
                
                MobileForm.FormDelegateSeparator {}
                
                MobileForm.FormTextDelegate {
                    text: i18n("Qt Version")
                    description: kcm.softwareInfo.qtVersion
                }
                
                MobileForm.FormDelegateSeparator {}
                
                MobileForm.FormTextDelegate {
                    text: i18n("Kernel Version")
                    description: kcm.softwareInfo.kernelRelease
                }
                
                MobileForm.FormDelegateSeparator {}
                
                MobileForm.FormTextDelegate {
                    text: i18n("OS Type")
                    description: i18nc("@label %1 is the CPU bit width (e.g. 32 or 64)", "%1-bit", kcm.softwareInfo.osType)
                }
            }
        }
        
        MobileForm.FormCard {
            Layout.fillWidth: true
            Layout.topMargin: Kirigami.Units.largeSpacing
            
            contentItem: ColumnLayout {
                spacing: 0
                
                MobileForm.FormCardHeader {
                    title: "Hardware"
                }
                
                MobileForm.FormTextDelegate {
                    text: i18np("Processor", "Processors", kcm.hardwareInfo.processorCount);
                    description: kcm.hardwareInfo.processors
                }
                
                MobileForm.FormDelegateSeparator {}
                
                MobileForm.FormTextDelegate {
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
        }
    }

    footer: RowLayout {
        Item {
            Layout.fillWidth: true
        }

        Controls.Button {
            text: i18n("Copy to clipboard")
            icon.name: "edit-copy"
            onClicked: kcm.copyInfoToClipboard()
        }
    }
}
