/***************************************************************************
 *                                                                         *
 *   Copyright 2011 Sebastian Kügler <sebas@kde.org>                       *
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
#include <QDeclarativeEngine>
#include <QScriptValue>

#include <KStandardDirs>

#include "view.h"
#include "kdebug.h"

View::View(const QString &url, QWidget *parent)
    : QDeclarativeView(parent)
{
    // Tell the script engine where to find the Plasma Quick components
    QStringList importPathes = KGlobal::dirs()->findDirs("lib", "kde4/imports");
    foreach (const QString &iPath, importPathes) {
        //kDebug() << "Adding import path to engine:" << iPath;
        engine()->addImportPath(iPath);
    }

    // Make the url passed in as argument known to the webbrowser component
    //kDebug() << "Setting startupArguments to " << url;
    rootContext()->setContextProperty("startupArguments", QVariant(QStringList(url)));

    // Locate the webbrowser QML component in the package
    // Note that this is a bit brittle, since it relies on the package name,
    // but it allows us to share the same code with the pure QML plasmoid
    // In a later stadium, we can install the QML stuff in a different path.
    QString qmlFile = KGlobal::dirs()->findResource("data", "plasma/plasmoids/qtwebbrowser/contents/code/webbrowser.qml");
    //kDebug() << "Loading QML File:" << qmlFile;
    setSource(QUrl(qmlFile));
    //kDebug() << "Plugin pathes:" << engine()->pluginPathList();
    show();

    //connect(engine(), SIGNAL(signalHandlerException(QScriptValue)), this, SLOT(exception()));
}

View::~View()
{
}

void View::exception()
{   // TODO: do something useful, in case anything goes wrong in the QML files
    kDebug() << "Exception in script.";
}

#include "view.moc"
