/*
    SPDX-FileCopyrightText: 2020 Bhushan Shah <bshah@kde.org>
    SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>

    SPDX-License-Identifier: LGPL-2.0-or-later
*/

import QtQuick 2.7
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.11 as QQC2

import org.kde.kirigami 2.19 as Kirigami
import org.kde.kcmutils as KCM
import org.kde.kitemmodels 1.0 as KItemModel
import org.kde.kirigamiaddons.formcard 1.0 as FormCard

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

        FormCard.FormCard {
            FormCard.FormTextFieldDelegate {
                label: i18n("Type anything here…")
            }
        }

        FormCard.FormHeader {
            title: i18nc("@title:group", "Feedback")
        }

        FormCard.FormCard {
            FormCard.FormSwitchDelegate {
                id: firstFeedbackCheckBox
                text: i18n("Sound")
                description: i18n("Whether to emit a sound on keypress.")
                checked: kcm.soundFeedback
                onCheckedChanged: kcm.soundFeedback = checked;
            }

            FormCard.FormDelegateSeparator { above: firstFeedbackCheckBox; below: secondFeedbackCheckBox }

            FormCard.FormSwitchDelegate {
                id: secondFeedbackCheckBox
                text: i18n("Vibration")
                description: i18n("Whether to vibrate on keypress.")
                checked: kcm.vibrateFeedback
                onCheckedChanged: kcm.vibrateFeedback = checked;
            }
        }

        FormCard.FormHeader {
            title: i18nc("@title:group", "Text Correction")
        }

        FormCard.FormCard {

            FormCard.FormCheckDelegate {
                id: firstTextCorrectionCheckBox
                text: i18n("Check spelling of entered text")
                checked: kcm.spellCheck
                onCheckedChanged: kcm.spellCheck = checked;
            }

            FormCard.FormDelegateSeparator { above: firstTextCorrectionCheckBox; below: capitalizeCheck }

            FormCard.FormCheckDelegate {
                id: capitalizeCheck
                text: i18n("Capitalize the first letter of each sentence")
                checked: kcm.autoCapitalize
                onCheckedChanged: kcm.autoCapitalize = checked;
            }

            FormCard.FormDelegateSeparator { above: capitalizeCheck; below: wordCompletionCheck }

            FormCard.FormCheckDelegate {
                id: wordCompletionCheck
                text: i18n("Complete current word with first suggestion when hitting space")
                checked: kcm.autoCompleteOnSpace
                onCheckedChanged: kcm.autoCompleteOnSpace = checked;
            }

            FormCard.FormDelegateSeparator { above: wordCompletionCheck; below: wordSuggestionCheck }

            FormCard.FormCheckDelegate {
                id: wordSuggestionCheck
                text: i18n("Suggest potential words in word ribbon")
                checked: kcm.showSuggestions
                onCheckedChanged: {
                    kcm.showSuggestions = checked;
                }
            }

            FormCard.FormDelegateSeparator { above: wordSuggestionCheck; below: fullStopCheck }

            FormCard.FormCheckDelegate {
                id: fullStopCheck
                text: i18n("Insert a full-stop when space is pressed twice")
                checked: kcm.fullStopOnDoubleSpace
                onCheckedChanged: {
                    kcm.fullStopOnDoubleSpace = checked;
                }
            }

            FormCard.FormDelegateSeparator { above: fullStopCheck; below: languageButton }

            FormCard.FormButtonDelegate {
                id: languageButton
                text: i18n("Configure Languages")
                icon.name: "set-language"
                onClicked: kcm.push("languages.qml")
            }
        }
    }
}
