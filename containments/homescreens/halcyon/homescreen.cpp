// SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "homescreen.h"

#include <KIO/ApplicationLauncherJob>
#include <KWindowSystem>

#include <QDebug>
#include <QQuickItem>
#include <QtQml>

HomeScreen::HomeScreen(QObject *parent, const KPluginMetaData &data, const QVariantList &args)
    : Plasma::Containment{parent, data, args}
{
    setHasConfigurationInterface(true);
}

HomeScreen::~HomeScreen() = default;

K_PLUGIN_CLASS_WITH_JSON(HomeScreen, "package/metadata.json")

#include "homescreen.moc"
