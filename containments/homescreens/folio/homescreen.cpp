// SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>
// SPDX-FileCopyrightText: 2022-2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "homescreen.h"

#include <KWindowSystem>

#include <QDebug>
#include <QQmlEngine>
#include <QQmlExtensionPlugin>
#include <QQuickItem>

K_PLUGIN_CLASS_WITH_JSON(HomeScreen, "metadata.json")

HomeScreen::HomeScreen(QObject *parent, const KPluginMetaData &data, const QVariantList &args)
    : Plasma::Containment{parent, data, args}
    , m_folioSettings{new FolioSettings{this}}
    , m_homeScreenState{new HomeScreenState{this}}
    , m_widgetsManager{new WidgetsManager{this}}
    , m_applicationListModel{new ApplicationListModel{this}}
    , m_applicationListSearchModel{new ApplicationListSearchModel{this, m_applicationListModel}}
    , m_favouritesModel{new FavouritesModel{this}}
    , m_pageListModel{new PageListModel{this}}
{
    // HomeScreenState init() has dependencies on other objects
    m_homeScreenState->init();

    setHasConfigurationInterface(true);

    connect(KWindowSystem::self(), &KWindowSystem::showingDesktopChanged, this, &HomeScreen::showingDesktopChanged);

    connect(this, &Plasma::Containment::appletAdded, this, &HomeScreen::onAppletAdded);
    connect(this, &Plasma::Containment::appletAboutToBeRemoved, this, &HomeScreen::onAppletAboutToBeRemoved);
}

HomeScreen::~HomeScreen() = default;

void HomeScreen::configChanged()
{
    Plasma::Containment::configChanged();
}

void HomeScreen::onAppletAdded(Plasma::Applet *applet, const QRectF &geometryHint)
{
    Q_UNUSED(geometryHint)
    widgetsManager()->addWidget(applet);
}

void HomeScreen::onAppletAboutToBeRemoved(Plasma::Applet *applet)
{
    widgetsManager()->removeWidget(applet);
}

FolioSettings *HomeScreen::folioSettings()
{
    return m_folioSettings;
}

HomeScreenState *HomeScreen::homeScreenState()
{
    return m_homeScreenState;
}

WidgetsManager *HomeScreen::widgetsManager()
{
    return m_widgetsManager;
}

ApplicationListModel *HomeScreen::applicationListModel()
{
    return m_applicationListModel;
}

ApplicationListSearchModel *HomeScreen::applicationListSearchModel()
{
    return m_applicationListSearchModel;
}

FavouritesModel *HomeScreen::favouritesModel()
{
    return m_favouritesModel;
}

PageListModel *HomeScreen::pageListModel()
{
    return m_pageListModel;
}

#include "homescreen.moc"
