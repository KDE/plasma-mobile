/*
    SPDX-FileCopyrightText: 2020 Bhushan Shah <bshah@kde.org>
    SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>

    SPDX-License-Identifier: LGPL-2.0-or-later
*/

import QtQuick 2.7
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.11 as QQC2

import org.kde.kirigami 2.19 as Kirigami
import org.kde.kcm 1.3 as KCM
import org.kde.kitemmodels 1.0 as KItemModel
import org.kde.kirigamiaddons.labs.mobileform 0.1 as MobileForm

KCM.SimpleKCM {
    id: root

    title: i18n("On-Screen Keyboard")

    leftPadding: 0
    rightPadding: 0
    topPadding: Kirigami.Units.gridUnit
    bottomPadding: Kirigami.Units.gridUnit
    
    ColumnLayout {
        spacing: 0
        width: parent.width
        
        MobileForm.FormCard {
            Layout.fillWidth: true
            
            contentItem: ColumnLayout {
                spacing: 0
                
                MobileForm.AbstractFormDelegate {
                    Layout.fillWidth: true
                    background: Item {}
                    contentItem: RowLayout {
                        QQC2.TextField {
                            Layout.fillWidth: true
                            placeholderText: i18n("Type anything here…")
                        }
                    }
                }
            }
        }
        
        MobileForm.FormCard {
            Layout.topMargin: Kirigami.Units.largeSpacing
            Layout.fillWidth: true
            
            contentItem: ColumnLayout {
                spacing: 0
                
                MobileForm.FormCardHeader {
                    title: "Feedback"
                }
                
                MobileForm.FormSwitchDelegate {
                    id: firstFeedbackCheckBox
                    text: i18n("Sound")
                    description: i18n("Whether to emit a sound on keypress.")
                    checked: kcm.soundFeedback
                    onCheckedChanged: kcm.soundFeedback = checked;
                }

                MobileForm.FormDelegateSeparator { above: firstFeedbackCheckBox; below: secondFeedbackCheckBox }
                
                MobileForm.FormSwitchDelegate {
                    id: secondFeedbackCheckBox
                    text: i18n("Vibration")
                    description: i18n("Whether to vibrate on keypress.")
                    checked: kcm.vibrateFeedback
                    onCheckedChanged: kcm.vibrateFeedback = checked;
                }
            }
        }
        
        MobileForm.FormCard {
            Layout.topMargin: Kirigami.Units.largeSpacing
            Layout.fillWidth: true
            
            contentItem: ColumnLayout {
                spacing: 0
                
                MobileForm.FormCardHeader {
                    title: "Text Correction"
                }
                
                MobileForm.FormCheckDelegate {
                    id: firstTextCorrectionCheckBox
                    text: i18n("Check spelling of entered text")
                    checked: kcm.spellCheck
                    onCheckedChanged: kcm.spellCheck = checked;
                }
                
                MobileForm.FormDelegateSeparator { above: firstTextCorrectionCheckBox; below: capitalizeCheck }

                MobileForm.FormCheckDelegate {
                    id: capitalizeCheck
                    text: i18n("Capitalize the first letter of each sentence")
                    checked: kcm.autoCapitalize
                    onCheckedChanged: kcm.autoCapitalize = checked;
                }
                
                MobileForm.FormDelegateSeparator { above: capitalizeCheck; below: wordCompletionCheck }

                MobileForm.FormCheckDelegate {
                    id: wordCompletionCheck
                    text: i18n("Complete current word with first suggestion when hitting space")
                    checked: kcm.autoCompleteOnSpace
                    onCheckedChanged: kcm.autoCompleteOnSpace = checked;
                }
                
                MobileForm.FormDelegateSeparator { above: wordCompletionCheck; below: wordSuggestionCheck }

                MobileForm.FormCheckDelegate {
                    id: wordSuggestionCheck
                    text: i18n("Suggest potential words in word ribbon")
                    checked: kcm.showSuggestions
                    onCheckedChanged: {
                        kcm.showSuggestions = checked;
                    }
                }
                
                MobileForm.FormDelegateSeparator { above: wordSuggestionCheck; below: fullStopCheck }
                
                MobileForm.FormCheckDelegate {
                    id: fullStopCheck
                    text: i18n("Insert a full-stop when space is pressed twice")
                    checked: kcm.fullStopOnDoubleSpace
                    onCheckedChanged: {
                        kcm.fullStopOnDoubleSpace = checked;
                    }
                }
                
                MobileForm.FormDelegateSeparator { above: fullStopCheck; below: languageButton }
                
                MobileForm.FormButtonDelegate {
                    id: languageButton
                    text: i18n("Configure Languages")
                    icon.name: "set-language"
                    onClicked: kcm.push("languages.qml")
                }
            }
        }
    }
}
