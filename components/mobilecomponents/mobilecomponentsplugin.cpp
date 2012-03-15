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

#include <QtDeclarative/qdeclarative.h>
#include <QDeclarativeEngine>

#include "appletcontainer.h"
#include "categorizedproxymodel.h"
#include "pagedproxymodel.h"
#include "fallbackcomponent.h"
#include "package.h"
#include "texteffects.h"
#include "appbackgroundprovider_p.h"

void MobileComponentsPlugin::initializeEngine(QDeclarativeEngine *engine, const char *uri)
{
    engine->addImageProvider(QLatin1String("appbackgrounds"), new AppBackgroundProvider);
}

void MobileComponentsPlugin::registerTypes(const char *uri)
{
    Q_ASSERT(uri == QLatin1String("org.kde.plasma.mobilecomponents"));

    qmlRegisterType<PagedProxyModel>(uri, 0, 1, "PagedProxyModel");
    qmlRegisterType<FallbackComponent>(uri, 0, 1, "FallbackComponent");
    qmlRegisterType<CategorizedProxyModel>(uri, 0, 1, "CategorizedProxyModel");
    qmlRegisterType<Package>(uri, 0, 1, "Package");
    qmlRegisterType<TextEffects>(uri, 0, 1, "TextEffects");
    qmlRegisterType<AppletContainer>(uri, 0, 1, "AppletContainer");
}


#include "mobilecomponentsplugin.moc"

