/*
 *   Copyright 2019 by Marco Martin <mart@kde.org>

 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU Library General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
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
