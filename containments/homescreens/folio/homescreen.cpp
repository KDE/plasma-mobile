// SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>
// SPDX-FileCopyrightText: 2022-2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "homescreen.h"

#include "applicationlistmodel.h"
#include "delegatetoucharea.h"
#include "favouritesmodel.h"
#include "folioapplication.h"
#include "folioapplicationfolder.h"
#include "foliodelegate.h"
#include "foliosettings.h"
#include "foliowidget.h"
#include "homescreenstate.h"
#include "pagelistmodel.h"
#include "pagemodel.h"
#include "widgetcontainer.h"
#include "widgetsmanager.h"

#include <KWindowSystem>

#include <QDebug>
#include <QQmlEngine>
#include <QQmlExtensionPlugin>
#include <QQuickItem>
#include <QtQml>

HomeScreen::HomeScreen(QObject *parent, const KPluginMetaData &data, const QVariantList &args)
    : Plasma::Containment{parent, data, args}
{
    setHasConfigurationInterface(true);
    const char *uri = "org.kde.private.mobile.homescreen.folio";

    // pre-initialize
    FolioSettings::self()->setApplet(this);
    HomeScreenState::self()->setContainment(this);
    WidgetsManager::self();

    // models are loaded in main.qml
    ApplicationListModel::self();
    FavouritesModel::self()->setContainment(this);
    PageListModel::self()->setContainment(this);

    qmlRegisterSingletonType<ApplicationListModel>(uri, 1, 0, "ApplicationListModel", [](QQmlEngine *, QJSEngine *) -> QObject * {
        return ApplicationListModel::self();
    });

    qmlRegisterSingletonType<FavouritesModel>(uri, 1, 0, "FavouritesModel", [](QQmlEngine *, QJSEngine *) -> QObject * {
        return FavouritesModel::self();
    });

    qmlRegisterSingletonType<PageListModel>(uri, 1, 0, "PageListModel", [](QQmlEngine *, QJSEngine *) -> QObject * {
        return PageListModel::self();
    });

    qmlRegisterSingletonType<FolioSettings>(uri, 1, 0, "FolioSettings", [](QQmlEngine *, QJSEngine *) -> QObject * {
        return FolioSettings::self();
    });

    qmlRegisterSingletonType<HomeScreenState>(uri, 1, 0, "HomeScreenState", [](QQmlEngine *, QJSEngine *) -> QObject * {
        return HomeScreenState::self();
    });

    qmlRegisterType<FolioApplication>(uri, 1, 0, "FolioApplication");
    qmlRegisterType<FolioApplicationFolder>(uri, 1, 0, "FolioApplicationFolder");
    qmlRegisterType<FolioWidget>(uri, 1, 0, "FolioWidget");
    qmlRegisterType<FolioDelegate>(uri, 1, 0, "FolioDelegate");
    qmlRegisterType<PageModel>(uri, 1, 0, "PageModel");
    qmlRegisterType<FolioPageDelegate>(uri, 1, 0, "FolioPageDelegate");
    qmlRegisterType<DelegateTouchArea>(uri, 1, 0, "DelegateTouchArea");
    qmlRegisterType<DelegateDragPosition>(uri, 1, 0, "DelegateDragPosition");
    qmlRegisterType<WidgetContainer>(uri, 1, 0, "WidgetContainer");

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
    WidgetsManager::self()->addWidget(applet);
}

void HomeScreen::onAppletAboutToBeRemoved(Plasma::Applet *applet)
{
    WidgetsManager::self()->removeWidget(applet);
}

K_PLUGIN_CLASS(HomeScreen)

#include "homescreen.moc"
