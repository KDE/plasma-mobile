// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "settings.h"

#include <KConfigGroup>
#include <KRuntimePlatform>

const QString CONFIG_FILE = QStringLiteral("plasmamobilerc");
const QString INITIAL_START_CONFIG_GROUP = QStringLiteral("InitialStart");

Settings::Settings(QObject *parent)
    : QObject{parent}
    , m_mobileConfig{KSharedConfig::openConfig(CONFIG_FILE)}
    , m_isMobilePlatform{KRuntimePlatform::runtimePlatform().contains(QStringLiteral("phone"))}
{
}

bool Settings::shouldStartWizard()
{
    if (!m_isMobilePlatform) {
        return false;
    }

    auto group = KConfigGroup{m_mobileConfig, INITIAL_START_CONFIG_GROUP};
    return !group.readEntry("wizardRun", false);
}

void Settings::setWizardFinished()
{
    auto group = KConfigGroup{m_mobileConfig, INITIAL_START_CONFIG_GROUP};
    group.writeEntry("wizardRun", true, KConfigGroup::Notify);
    m_mobileConfig->sync();
}

Settings *Settings::self()
{
    static auto instance = new Settings;
    return instance;
}
