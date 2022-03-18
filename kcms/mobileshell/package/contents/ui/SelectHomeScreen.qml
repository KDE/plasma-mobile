/*
 * SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
 * SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15 as QQC2

import org.kde.kirigami 2.19 as Kirigami
import org.kde.kcm 1.3 as KCM
import org.kde.plasma.private.mobileshell 1.0 as MobileShell

import "mobileform" as MobileForm

Kirigami.ScrollablePage {
    id: root
    title: i18n("Select Launcher Type")
    
    leftPadding: 0
    rightPadding: 0
    topPadding: Kirigami.Units.largeSpacing
    bottomPadding: Kirigami.Units.largeSpacing
    
    MobileForm.FormCard {
        Layout.fillWidth: true
        Layout.topMargin: Kirigami.Units.largeSpacing
        
        contentItem: ColumnLayout {
            spacing: 0
            
            MobileForm.FormCardHeader {
                subtitle: i18n("Select the launcher type to use for the home screen.")
            }
            
            MobileShell.HomeScreenModel {
                id: homeScreenModel
            }
            
            Repeater {
                model: homeScreenModel
                
                delegate: MobileForm.FormRadioButtonDelegate {
                    id: radioDelegate
                    
                    text: model.name
                    description: model.description
                    
                    checked: homeScreenModel.selectedHomeScreen === model.id
                    onCheckedChanged: {
                        if (checked && homeScreenModel.selectedHomeScreen !== model.id) {
                            homeScreenModel.selectedHomeScreen = model.id;
                        }
                    }
                    
                    Connections {
                        target: homeScreenModel
                        function onSelectedHomeScreenChanged() {
                            radioDelegate.checked = homeScreenModel.selectedHomeScreen === model.id;
                        }
                    }
                }
            }
        }
    }
}
