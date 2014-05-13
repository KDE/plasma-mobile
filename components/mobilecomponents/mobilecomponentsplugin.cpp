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

#include "mobilecomponentsplugin.h"

#include <QQmlExtensionPlugin>
#include <QQmlEngine>
#include <QQmlContext>
#include <kdeclarative/kdeclarative.h>

#include "pagedproxymodel.h"
#include "fallbackcomponent.h"
#include "package.h"
#include "texteffects.h"

void MobileComponentsPlugin::initializeEngine(QQmlEngine *engine, const char *uri)
{
    QQmlExtensionPlugin::initializeEngine(engine, uri);

    if (!engine->rootContext()->contextObject()) {
        KDeclarative::KDeclarative kdeclarative;
        kdeclarative.setDeclarativeEngine(engine);
        kdeclarative.setupBindings();
    }
}

void MobileComponentsPlugin::registerTypes(const char *uri)
{
    Q_ASSERT(uri == QLatin1String("org.kde.plasma.mobilecomponents"));

    qmlRegisterType<PagedProxyModel>(uri, 0, 2, "PagedProxyModel");
    qmlRegisterType<FallbackComponent>(uri, 0, 2, "FallbackComponent");
    qmlRegisterType<Package>(uri, 0, 2, "Package");
    qmlRegisterType<TextEffects>(uri, 0, 2, "TextEffects");
}


#include "mobilecomponentsplugin.moc"

