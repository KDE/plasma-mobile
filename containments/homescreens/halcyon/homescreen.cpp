// SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "homescreen.h"

#include <KIO/ApplicationLauncherJob>
#include <KWindowSystem>

#include <QDebug>
#include <QQuickItem>

K_PLUGIN_CLASS_WITH_JSON(HomeScreen, "metadata.json")

HomeScreen::HomeScreen(QObject *parent, const KPluginMetaData &data, const QVariantList &args)
    : Plasma::Containment{parent, data, args}
    , m_settings{new HalcyonSettings{this, config()}}
    , m_pinnedModel{new PinnedModel{this}}
{
    setHasConfigurationInterface(true);
}

HomeScreen::~HomeScreen() = default;

HalcyonSettings *HomeScreen::settings() const
{
    return m_settings;
}

PinnedModel *HomeScreen::pinnedModel() const
{
    return m_pinnedModel;
}

#include "homescreen.moc"
