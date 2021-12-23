/*
 * SPDX-FileCopyrightText: 2019 by Marco Martin <mart@kde.org>
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

#include "mobilehomescreencomponentsplugin.h"

#include <QQmlContext>
#include <QQuickItem>

#include "applicationlistmodel.h"
#include "favoritesmodel.h"
#include "homescreenutils.h"

void MobileHomeScreenComponentsPlugin::registerTypes(const char *uri)
{
    Q_ASSERT(QLatin1String(uri) == QLatin1String("org.kde.plasma.private.mobilehomescreencomponents"));

    qmlRegisterSingletonType<HomeScreenUtils>(uri, 0, 1, "HomeScreenUtils",
                                              [](QQmlEngine *, QJSEngine *) {
        return new HomeScreenUtils{};
    });

    qmlRegisterSingletonType<ApplicationListModel>(uri, 0, 1, "ApplicationListModel", 
                                                   [](QQmlEngine *, QJSEngine *) {
        return new ApplicationListModel{};
    });

    qmlRegisterSingletonType<FavoritesModel>(uri, 0, 1, "FavoritesModel", 
                                                   [](QQmlEngine *, QJSEngine *) {
        return new FavoritesModel{};
    });

    //  qmlProtectModule(uri, 1);
}

//#include "moc_mobilehomescreencomponentplugin.cpp"
