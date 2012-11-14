/*
 *   Copyright 2011 by Marco Martin <mart@kde.org>

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

#include "datamodelsplugin.h"

#include <QtDeclarative/qdeclarative.h>

#include <Plasma/Service>

#include "metadatamodel.h"
#include "metadatausertypes.h"
#include "queryproviders/basicqueryprovider.h"
#include "queryproviders/resourcequeryprovider.h"
#include "queryproviders/cloudqueryprovider.h"
#include "queryproviders/timelinequeryprovider.h"

void DataModelsPlugin::registerTypes(const char *uri)
{
    Q_ASSERT(uri == QLatin1String("org.kde.metadatamodels"));

    qmlRegisterType<BasicQueryProvider>(uri, 0, 1, "BasicQueryProvider");
    qmlRegisterType<ResourceQueryProvider>(uri, 0, 1, "ResourceQueryProvider");
    qmlRegisterType<CloudQueryProvider>(uri, 0, 1, "CloudQueryProvider");
    qmlRegisterType<TimelineQueryProvider>(uri, 0, 1, "TimelineQueryProvider");
    

    qmlRegisterType<MetadataModel>(uri, 0, 1, "MetadataModel");
    qmlRegisterType<MetadataUserTypes>(uri, 0, 1, "MetadataUserTypes");

    qmlRegisterInterface<Plasma::Service>("Service");
    qRegisterMetaType<Plasma::Service*>("Service");
    qmlRegisterInterface<Plasma::ServiceJob>("ServiceJob");
    qRegisterMetaType<Plasma::ServiceJob*>("ServiceJob");
}


#include "datamodelsplugin.moc"

