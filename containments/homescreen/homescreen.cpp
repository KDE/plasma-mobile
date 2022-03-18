/*
    SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>
    SPDX-License-Identifier: GPL-2.0-or-later
 */

#include "homescreen.h"

#include <KPackage/PackageLoader>
#include <KWindowSystem>

#include <QDebug>
#include <QQuickItem>
#include <QtQml>

#include <mobileshellsettings.h>

HomeScreen::HomeScreen(QObject *parent, KPluginMetaData metaData, const QVariantList &args)
    : Plasma::Containment(parent, metaData, args)
{
    setHasConfigurationInterface(true);
    connect(KWindowSystem::self(), &KWindowSystem::showingDesktopChanged, this, &HomeScreen::showingDesktopChanged);
}

HomeScreen::~HomeScreen() = default;

void HomeScreen::configChanged()
{
    Plasma::Containment::configChanged();
}

void HomeScreen::stackBefore(QQuickItem *item1, QQuickItem *item2)
{
    if (!item1 || !item2 || item1 == item2 || item1->parentItem() != item2->parentItem()) {
        return;
    }

    item1->stackBefore(item2);
}

void HomeScreen::stackAfter(QQuickItem *item1, QQuickItem *item2)
{
    if (!item1 || !item2 || item1 == item2 || item1->parentItem() != item2->parentItem()) {
        return;
    }

    item1->stackAfter(item2);
}

bool HomeScreen::showingDesktop() const
{
    return KWindowSystem::showingDesktop();
}

void HomeScreen::setShowingDesktop(bool showingDesktop)
{
    KWindowSystem::setShowingDesktop(showingDesktop);
}

void HomeScreen::changeHomeScreenContainment()
{
    QString containmentId = MobileShell::MobileShellSettings::self()->homeScreenType();
    QString containmentName = "Folio"; // use default if specified containment is not found

    const auto packages = KPackage::PackageLoader::self()->listPackages(QStringLiteral("Plasma/Applet"), "plasma/plasmoids");

    // find name for homescreen containment
    for (const auto &metaData : packages) {
        const QStringList provides = metaData.value(QStringLiteral("X-Plasma-Provides"), QStringList());

        // check if the type of the containment is a homescreen
        if (!provides.contains("org.kde.phone.homescreen")) {
            continue;
        }

        if (containmentId == metaData.pluginId()) {
            containmentName = metaData.name();
        }
    }

    // delete all existing containments
    for (auto *applet : applets()) {
        applet->destroy();
    }

    // load new homescreen containment
    createApplet(containmentName);
}

K_PLUGIN_CLASS_WITH_JSON(HomeScreen, "metadata.json")

#include "homescreen.moc"
