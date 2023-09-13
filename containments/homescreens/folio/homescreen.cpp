// SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>
// SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "homescreen.h"

#include <KWindowSystem>

#include <QDebug>
#include <QQuickItem>
#include <QtQml>

HomeScreen::HomeScreen(QObject *parent, const KPluginMetaData &data, const QVariantList &args)
    : Plasma::Containment{parent, data, args}
{
    setHasConfigurationInterface(true);
    connect(KWindowSystem::self(), &KWindowSystem::showingDesktopChanged, this, &HomeScreen::showingDesktopChanged);
}

HomeScreen::~HomeScreen() = default;

void HomeScreen::configChanged()
{
    Plasma::Containment::configChanged();
}

K_PLUGIN_CLASS(HomeScreen)

#include "homescreen.moc"
