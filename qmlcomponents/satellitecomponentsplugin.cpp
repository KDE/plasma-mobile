/*
 *   Copyright 2009 by Alan Alpert <alan.alpert@nokia.com>
 *   Copyright 2010 by Ménard Alexis <menard@kde.org>
 *   Copyright 2010 by Marco Martin <mart@kde.org>

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

#include "satellitecomponentsplugin.h"

#include <QtQml>
#include <QQmlExtensionPlugin>
#include <QQmlEngine>
#include <QQmlContext>
#include <kdeclarative/kdeclarative.h>

#include "applicationlistmodel.h"
#include "favoritesmodel.h"

void SatelliteComponentsPlugin::initializeEngine(QQmlEngine *engine, const char *uri)
{
    QQmlExtensionPlugin::initializeEngine(engine, uri);

    if (!engine->rootContext()->contextObject()) {
        KDeclarative::KDeclarative kdeclarative;
        kdeclarative.setDeclarativeEngine(engine);
        kdeclarative.setupBindings();
    }
}

void SatelliteComponentsPlugin::registerTypes(const char *uri)
{
    Q_ASSERT(uri == QLatin1String("org.kde.satellite.components"));

    qmlRegisterType<ApplicationListModel>(uri, 0, 1, "ApplicationListModel");
    qmlRegisterType<FavoritesModel>();
}


#include "satellitecomponentsplugin.moc"

