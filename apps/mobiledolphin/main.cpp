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

#include <QApplication>

#include <QDeclarativeItem>
#include <QDeclarativeContext>
#include <kdeclarative.h>

#include "mobiledolphin.h"
    
KDeclarativeDirModel::KDeclarativeDirModel()
    : KDirModel(0)
{
    QHash<int, QByteArray> roles;
    roles[KDirModel::Name] = "name";
    roles[KDirModel::Size] = "size";
    roles[Qt::DecorationRole] = "decoration";
    setRoleNames(roles);
}

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);

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
    view.setSource(QUrl::fromLocalFile("mobiledolphin.qml"));
    QObject::connect(view.rootObject(), SIGNAL(fileClicked(QString)), &view, SLOT(changeDir(QString)));
    
    view.show();

    return app.exec();
}
