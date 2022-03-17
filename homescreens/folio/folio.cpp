/*
    SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>
    SPDX-License-Identifier: GPL-2.0-or-later
 */

#include "folio.h"

#include "applicationlistmodel.h"
#include "favoritesmodel.h"
#include "homescreenutils.h"

#include "quicksetting.h"

#include <QJSEngine>
#include <QQmlEngine>

Folio::Folio(QObject *parent, KPluginMetaData pluginMetaData, const QVariantList &args)
    : Plasma::Containment(parent, pluginMetaData, args)
{
    auto uri = "org.kde.phone.homescreen.folio";
    qmlRegisterSingletonType<HomeScreenUtils>(uri, 0, 1, "HomeScreenUtils", [](QQmlEngine *, QJSEngine *) {
        return new HomeScreenUtils{};
    });

    qmlRegisterSingletonType<ApplicationListModel>(uri, 0, 1, "ApplicationListModel", [](QQmlEngine *, QJSEngine *) {
        return new ApplicationListModel{};
    });

    qmlRegisterSingletonType<FavoritesModel>(uri, 0, 1, "FavoritesModel", [](QQmlEngine *, QJSEngine *) {
        return new FavoritesModel{};
    });

    setHasConfigurationInterface(true);
}

Folio::~Folio() = default;

void Folio::configChanged()
{
    Plasma::Containment::configChanged();
}

K_PLUGIN_CLASS_WITH_JSON(Folio, "metadata.json")

#include "folio.moc"
