/*
 * Copyright 2009 Chani Armitage <chani@kde.org>
 * Copyright 2011 Marco Martin <mart@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License version 2 as
 *   published by the Free Software Foundation
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

#include "appsengine.h"
#include "appsource.h"
#include "appservice.h"
#include "categoriessource.h"
#include "groupsource.h"
#include "groupssource.h"


AppsEngine::AppsEngine(QObject *parent, const QVariantList &args) :
    Plasma::DataEngine(parent, args)
{
    Q_UNUSED(args);
}

AppsEngine::~AppsEngine()
{
}

bool AppsEngine::sourceRequestEvent(const QString &name)
{
    if (containerForSource(name)) {
        return true;
    }

    if (name.startsWith("Apps")) {
        AppSource *appSource = new AppSource(name, this);
        addSource(appSource);
        return true;
    } else if (name.startsWith("Categories")) {
        CategoriesSource *catSource = new CategoriesSource(name, this);
        addSource(catSource);
        return true;
    } else if (name.startsWith("Groups")) {
        GroupsSource *grpsSource = new GroupsSource(name, this);
        addSource(grpsSource);
        return true;
    } else if (name.startsWith("Group")) {
        GroupSource *grpSource = new GroupSource(name, this);
        addSource(grpSource);
        return true;
    }

    return false;
}

Plasma::Service *AppsEngine::serviceForSource(const QString &name)
{
    if (name == "Groups") {
        return Plasma::DataEngine::serviceForSource(name);
    }

    AppSource *source = dynamic_cast<AppSource*>(containerForSource(name));
    // if source does not exist, return null service
    if (!source) {
        return Plasma::DataEngine::serviceForSource(name);
    }

    // if source is a group of apps, return real service
    Plasma::Service *service = new AppService(source);
    service->setParent(this);
    return service;
}

K_EXPORT_PLASMA_DATAENGINE(apps, AppsEngine)

#include "appsengine.moc"
