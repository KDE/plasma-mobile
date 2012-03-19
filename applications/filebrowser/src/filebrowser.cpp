/***************************************************************************
 *                                                                         *
 *   Copyright 2011 Sebastian Kügler <sebas@kde.org>                       *
 *   Copyright 2011 Marco Martin <mart@kde.org>                            *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA .        *
 ***************************************************************************/

#include "filebrowser.h"
#include "kdeclarativeview.h"

#include <QDeclarativeContext>
#include <QFileInfo>

#include <KAction>
#include <KCmdLineArgs>
#include <KConfigGroup>
#include <KIcon>
#include <KStandardAction>
#include <KServiceTypeTrader>

#include <Plasma/Theme>


FileBrowser::FileBrowser()
    : KDeclarativeMainWindow()
{
    KCmdLineArgs *args = KCmdLineArgs::parsedArgs();

    declarativeView()->setPackageName("org.kde.active.filebrowser");

    declarativeView()->rootContext()->setContextProperty("exclusiveResourceType", args->getOption("resourceType"));
}

FileBrowser::~FileBrowser()
{
}

QString FileBrowser::packageForMimeType(const QString &mimeType)
{
     KService::List services = KServiceTypeTrader::self()->query("Active/FileBrowserPart", QString("'%1' in MimeTypes").arg(mimeType));

     foreach (const KService::Ptr &service, services) {
        if (service->noDisplay()) {
            continue;
        }
        QString description;
        if (!service->genericName().isEmpty() && service->genericName() != service->name()) {
            description = service->genericName();
        } else if (!service->comment().isEmpty()) {
            description = service->comment();
        }
        //kDebug() << service->property("X-KDE-PluginInfo-Name") << " :: " << description;
        kDebug() << service->property("X-KDE-PluginInfo-Name") << "\t\t" << description.toLocal8Bit().data();
        return service->property("X-KDE-PluginInfo-Name").toString();
    }
    return QString();
}

#include "filebrowser.moc"
