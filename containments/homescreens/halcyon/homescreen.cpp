// SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "homescreen.h"

#include <KIO/ApplicationLauncherJob>
#include <KWindowSystem>

#include <QDebug>
#include <QQuickItem>

HomeScreen::HomeScreen(QObject *parent, const KPluginMetaData &data, const QVariantList &args)
    : Plasma::Containment{parent, data, args}
    , m_settings{new HalcyonSettings{this, config()}}
{
    setHasConfigurationInterface(true);
}

HomeScreen::~HomeScreen() = default;

HalcyonSettings *HomeScreen::settings() const
{
    return m_settings;
}

K_PLUGIN_CLASS(HomeScreen)

#include "homescreen.moc"
