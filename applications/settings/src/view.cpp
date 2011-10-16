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

#include "view.h"
#include "settingsmodulesmodel.h"

#include <QDeclarativeContext>
#include <QDeclarativeEngine>
#include <QDeclarativeItem>
#include <QScriptValue>

#include <KStandardDirs>
#include "Plasma/Package"

#include <kdeclarative.h>

View::View(const QString &module, QWidget *parent)
    : QDeclarativeView(parent),
    m_package(0)
{
    setResizeMode(QDeclarativeView::SizeRootObjectToView);
    // Tell the script engine where to find the Plasma Quick components
    QStringList importPathes = KGlobal::dirs()->findDirs("lib", "kde4/imports");
    foreach (const QString &iPath, importPathes) {
        engine()->addImportPath(iPath);
    }

    KDeclarative kdeclarative;
    kdeclarative.setDeclarativeEngine(engine());
    kdeclarative.initialize();
    //binds things like kconfig and icons
    kdeclarative.setupBindings();

    Plasma::PackageStructure::Ptr structure = Plasma::PackageStructure::load("Plasma/Generic");
    m_package = new Plasma::Package(QString(), "org.kde.active.settings", structure);

    setSource(QUrl(m_package->filePath("mainscript")));
    show();
    if (!module.isEmpty()) {
        kDebug() << "load model: " << module;
    }
    m_settingsModules = new SettingsModulesModel(this);

    //onStatusChanged(status());

    //connect(engine(), SIGNAL(signalHandlerException(QScriptValue)), this, SLOT(exception()));
    //connect(this, SIGNAL(statusChanged(QDeclarativeView::Status)),
    //        this, SLOT(onStatusChanged(QDeclarativeView::Status)));
}

View::~View()
{

    delete m_package;
}



#include "view.moc"
