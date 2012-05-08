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

#include <QDeclarativeContext>
#include <QFile>

#include <KAction>
#include <KIcon>
#include <KStandardAction>

#include <Plasma/Theme>

#include "aboutapp.h"
#include "kdeclarativeview.h"

AboutApp::AboutApp()
    : KDeclarativeMainWindow()
{
    declarativeView()->setPackageName("org.kde.active.aboutapp");
    
    //FIXME: find a prettier way
    QString fn;
    if (QFile::exists("/etc/image-release")) {
        fn = "/etc/image-release";
    } else {
        fn = "/etc/issue";
    }
    QFile f(fn);
    f.open(QIODevice::ReadOnly);
    const QString osVersion = f.readLine();

    declarativeView()->rootContext()->setContextProperty("runtimeInfoActiveVersion", "2.0");
    declarativeView()->rootContext()->setContextProperty("runtimeInfoKdeVersion", KDE::versionString());
    declarativeView()->rootContext()->setContextProperty("runtimeInfoOsVersion", osVersion);
}

AboutApp::~AboutApp()
{
    saveWindowSize(config("Window"));
}

#include "aboutapp.moc"
