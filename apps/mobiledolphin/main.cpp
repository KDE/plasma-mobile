/***************************************************************************
 *   Copyright 2011 by Davide Bettio <davide.bettio@kdemail.net>           *
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

#include <QDeclarativeItem>
#include <QDeclarativeContext>
#include <KAboutData>
#include <KApplication>
#include <KCmdLineArgs>
#include <kdeclarative.h>
#include <KCmdLineArgs>
#include <KStandardDirs>
#include <kdebug.h>

#include "mobiledolphin.h"

int main(int argc, char *argv[])
{
   KAboutData about("mobiledolphin", 0,
                     ki18nc("@title", "Mobile Dolphin"),
                     "0.1",
                     ki18nc("@title", "File Manager"),
                     KAboutData::License_GPL,
                     ki18nc("@info:credit", "(C) 2011 Davide Bettio"));

    KCmdLineArgs::init(argc, argv, &about);
    KApplication app;

    MobileDolphin view;

    KDeclarative kdeclarative;
    kdeclarative.setDeclarativeEngine(view.engine());
    kdeclarative.initialize();
    kdeclarative.setupBindings();

    view.lister = new KDirLister;
    view.lister->openUrl((app.arguments().count() == 2) ? KUrl(app.arguments().at(1)) : KUrl("file:///"));
    view.files = new KDeclarativeDirModel;
    view.files->setDirLister(view.lister);

    view.rootContext()->setContextProperty("myModel", view.files);
    view.rootContext()->setContextProperty("directory", view.lister->url().prettyUrl());
    view.setSource(QUrl::fromLocalFile(KStandardDirs::locate("data", "mobiledolphin/ui/mobiledolphin.qml")));
    QObject::connect(view.rootObject(), SIGNAL(fileClicked(QString)), &view, SLOT(changeDir(QString)));
    QObject::connect(view.rootObject(), SIGNAL(fileShowContextualMenu(QString)), &view, SLOT(showContextualMenu(QString)));

    view.show();

    return app.exec();
}
