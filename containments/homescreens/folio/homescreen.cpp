// SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>
// SPDX-FileCopyrightText: 2022-2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "homescreen.h"
#include "enums.h"

#include <KWindowSystem>

#include <QDebug>
#include <QQmlEngine>
#include <QQmlExtensionPlugin>
#include <QQuickItem>

HomeScreen::HomeScreen(QObject *parent, const KPluginMetaData &data, const QVariantList &args)
    : Plasma::Containment{parent, data, args}
    , m_folioSettings{new FolioSettings{this}}
    , m_homeScreenState{new HomeScreenState{this}}
    , m_widgetsManager{new WidgetsManager{this}}
    , m_applicationListModel{new ApplicationListModel{this}}
    , m_applicationListSearchModel{new ApplicationListSearchModel{this, m_applicationListModel}}
    , m_favouritesModel{new FavouritesModel{this}}
    , m_pageListModel{new PageListModel{this}}
    , m_keyboardNavigation{new KeyboardNavigation{this}}
{
    // HomeScreenState init() has dependencies on other objects
    m_homeScreenState->init();

    const char *uri = "org.kde.private.mobile.homescreen.folio";
    qmlRegisterUncreatableType<HomeScreen>(uri, 1, 0, "HomeScreen", "");
    qmlRegisterUncreatableType<ApplicationListModel>(uri, 1, 0, "ApplicationListModel", "");
    qmlRegisterUncreatableType<ApplicationListSearchModel>(uri, 1, 0, "ApplicationListSearchModel", "");
    qmlRegisterUncreatableType<FavouritesModel>(uri, 1, 0, "FavouritesModel", "");
    qmlRegisterUncreatableType<PageListModel>(uri, 1, 0, "PageListModel", "");
    qmlRegisterUncreatableType<FolioSettings>(uri, 1, 0, "FolioSettings", "");
    qmlRegisterUncreatableType<HomeScreenState>(uri, 1, 0, "HomeScreenState", "");
    qmlRegisterUncreatableType<FolioApplication>(uri, 1, 0, "FolioApplication", "");
    qmlRegisterUncreatableType<KeyboardNavigation>(uri, 1, 0, "KeyboardNavigation", "");
    qmlRegisterUncreatableType<FolioApplicationFolder>(uri, 1, 0, "FolioApplicationFolder", "");
    qmlRegisterUncreatableType<FolioWidget>(uri, 1, 0, "FolioWidget", "");
    qmlRegisterUncreatableType<FolioDelegate>(uri, 1, 0, "FolioDelegate", "");
    qmlRegisterUncreatableType<PageModel>(uri, 1, 0, "PageModel", "");
    qmlRegisterUncreatableType<FolioPageDelegate>(uri, 1, 0, "FolioPageDelegate", "");
    qmlRegisterType<DelegateTouchArea>(uri, 1, 0, "DelegateTouchArea");
    qmlRegisterUncreatableType<DelegateDragPosition>(uri, 1, 0, "DelegateDragPosition", "");
    qmlRegisterType<WidgetContainer>(uri, 1, 0, "WidgetContainer");
    qmlRegisterType<Enums>(uri, 1, 0, "Enums");

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

KeyboardNavigation *HomeScreen::keyboardNavigation()
{
    return m_keyboardNavigation;
}

K_PLUGIN_CLASS(HomeScreen)

#include "homescreen.moc"
