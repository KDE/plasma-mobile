/*
    SPDX-FileCopyrightText: 2020 Bhushan Shah <bshah@kde.org>

    SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
*/

#include "virtualkeyboard.h"
#include <KLocalizedString>
#include <KPluginFactory>

#include <QDir>

#include "languagemodel.h"

// clang-format off

#define SETTER(setter, member, gsetting, signal) \
    void VirtualKeyboard::setter(bool enabled) \
    { \
        if (member != enabled) {\
            member = enabled; \
            m_gsettings->set(gsetting, enabled); \
            Q_EMIT signal();\
        }\
    }

// clang-format on

K_PLUGIN_CLASS_WITH_JSON(VirtualKeyboard, "metadata.json")

VirtualKeyboard::VirtualKeyboard(QObject *parent, const KPluginMetaData &metaData, const QVariantList &args)
    : KQuickAddons::ConfigModule(parent, metaData, args)
    , m_gsettings(new GSettingsItem("/org/maliit/keyboard/maliit/", parent))
    , m_langModel(new LanguageModel(this, m_gsettings))
{
    qmlRegisterAnonymousType<LanguageModel>("org.kde.kcm.virtualkeyboard", 1);

    m_autoCapitalize = m_gsettings->value("auto-capitalization").toBool();
    m_autoCompleteOnSpace = m_gsettings->value("auto-completion").toBool();
    m_showSuggestions = m_gsettings->value("predictive-text").toBool();
    m_fullStopOnDoubleSpace = m_gsettings->value("double-space-full-stop").toBool();
    m_spellCheck = m_gsettings->value("spell-checking").toBool();

    m_soundFeedback = m_gsettings->value("key-press-feedback").toBool();
    m_vibrateFeedback = m_gsettings->value("key-press-haptic-feedback").toBool();
}

SETTER(setAutoCapitalize, m_autoCapitalize, "auto-capitalization", autoCapitalizeChanged)
SETTER(setAutoCompleteOnSpace, m_autoCompleteOnSpace, "auto-completion", autoCompleteOnSpaceChanged);
SETTER(setShowSuggestions, m_showSuggestions, "predictive-text", showSuggestionsChanged)
SETTER(setFullStopOnDoubleSpace, m_fullStopOnDoubleSpace, "double-space-full-stop", fullStopOnDoubleSpaceChanged)
SETTER(setSpellCheck, m_spellCheck, "spell-checking", spellCheckChanged)

SETTER(setSoundFeedback, m_soundFeedback, "key-press-feedback", soundFeedbackChanged)
SETTER(setVibrateFeedback, m_vibrateFeedback, "key-press-haptic-feedback", vibrateFeedbackChanged)

#include "virtualkeyboard.moc"
