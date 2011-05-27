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
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#include "mobilecomponentsplugin.h"

#include <QtDeclarative/qdeclarative.h>

#include "appletstatuswatcher.h"
#include "categorizedproxymodel.h"
#include "pagedproxymodel.h"
#include "fallbackcomponent.h"
#include "mouseeventlistener.h"

void MobileComponentsPlugin::registerTypes(const char *uri)
{
    Q_ASSERT(uri == QLatin1String("org.kde.plasma.mobilecomponents"));

    qmlRegisterType<PagedProxyModel>(uri, 0, 1, "PagedProxyModel");
    qmlRegisterType<AppletStatusWatcher>(uri, 0, 1, "AppletStatusWatcher");
    qmlRegisterType<FallbackComponent>(uri, 0, 1, "FallbackComponent");
    qmlRegisterType<CategorizedProxyModel>(uri, 0, 1, "CategorizedProxyModel");
    qmlRegisterType<MouseEventListener>(uri, 0, 1, "MouseEventListener");
}


#include "mobilecomponentsplugin.moc"

