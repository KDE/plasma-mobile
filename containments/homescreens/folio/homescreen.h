// SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>
// SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include <Plasma/Containment>
#include <QSortFilterProxyModel>

#include "applicationlistmodel.h"
#include "delegatetoucharea.h"
#include "favouritesmodel.h"
#include "folioapplication.h"
#include "folioapplicationfolder.h"
#include "foliodelegate.h"
#include "foliosettings.h"
#include "foliowidget.h"
#include "homescreenstate.h"
#include "keyboardnavigation.h"
#include "pagelistmodel.h"
#include "pagemodel.h"
#include "widgetcontainer.h"
#include "widgetsmanager.h"

class FolioSettings;
class PageListModel;
class WidgetsManager;
class HomeScreenState;
class FavouritesModel;
class ApplicationListModel;
class ApplicationListSearchModel;
class KeyboardNavigation;

class HomeScreen : public Plasma::Containment
{
    Q_OBJECT
    Q_PROPERTY(FolioSettings *FolioSettings READ folioSettings CONSTANT)
    Q_PROPERTY(HomeScreenState *HomeScreenState READ homeScreenState CONSTANT)
    Q_PROPERTY(WidgetsManager *WidgetsManager READ widgetsManager CONSTANT)
    Q_PROPERTY(ApplicationListModel *ApplicationListModel READ applicationListModel CONSTANT)
    Q_PROPERTY(ApplicationListSearchModel *ApplicationListSearchModel READ applicationListSearchModel CONSTANT)
    Q_PROPERTY(FavouritesModel *FavouritesModel READ favouritesModel CONSTANT)
    Q_PROPERTY(PageListModel *PageListModel READ pageListModel CONSTANT)
    Q_PROPERTY(KeyboardNavigation *KeyboardNavigation READ keyboardNavigation CONSTANT)

public:
    HomeScreen(QObject *parent, const KPluginMetaData &data, const QVariantList &args);
    ~HomeScreen() override;

    void configChanged() override;

    FolioSettings *folioSettings();
    HomeScreenState *homeScreenState();
    WidgetsManager *widgetsManager();
    ApplicationListModel *applicationListModel();
    ApplicationListSearchModel *applicationListSearchModel();
    FavouritesModel *favouritesModel();
    PageListModel *pageListModel();
    KeyboardNavigation *keyboardNavigation();

Q_SIGNALS:
    void showingDesktopChanged(bool showingDesktop);

private Q_SLOTS:
    void onAppletAdded(Plasma::Applet *applet, const QRectF &geometryHint);
    void onAppletAboutToBeRemoved(Plasma::Applet *applet);

private:
    FolioSettings *m_folioSettings{nullptr};
    HomeScreenState *m_homeScreenState{nullptr};
    WidgetsManager *m_widgetsManager{nullptr};
    ApplicationListModel *m_applicationListModel{nullptr};
    ApplicationListSearchModel *m_applicationListSearchModel{nullptr};
    FavouritesModel *m_favouritesModel{nullptr};
    PageListModel *m_pageListModel{nullptr};
    KeyboardNavigation *m_keyboardNavigation{nullptr};
};
