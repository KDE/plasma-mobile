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
#include "settingsmoduleloader.h"
#include "settingsmodule.h"

#include <QDeclarativeContext>
#include <QDeclarativeEngine>
#include <QDeclarativeItem>
#include <QScriptValue>
#include <QTimer>

//#include <KConfigGroup>
#include <KStandardDirs>
#include "Plasma/Package"

#include <kdeclarative.h>
#include "qscriptnonguibookkeeping.cpp"

View::View(const QString &module, QWidget *parent)
    : QDeclarativeView(parent),
    m_package(0),
    m_settingsRoot(0)
{
    setResizeMode(QDeclarativeView::SizeRootObjectToView);
    // Tell the script engine where to find the Plasma Quick components
    QStringList importPathes = KGlobal::dirs()->findDirs("lib", "kde4/imports");
    foreach (const QString &iPath, importPathes) {
        engine()->addImportPath(iPath);
        kDebug() << " IMPORT: " << iPath;
    }
    //qmlRegisterType<KConfigGroup>();

    KDeclarative kdeclarative;
    kdeclarative.setDeclarativeEngine(engine());
    kdeclarative.initialize();
    //binds things like kconfig and icons
    kdeclarative.setupBindings();

    Plasma::PackageStructure::Ptr structure = Plasma::PackageStructure::load("Plasma/Generic");
    m_package = new Plasma::Package(QString(), "org.kde.active.settings", structure);
    m_settingsModules = new SettingsModulesModel(this);
    if (!module.isEmpty()) {
        loadPlugin(module);
        rootContext()->setContextProperty("startModule", module);

    }
    rootContext()->setContextProperty("settingsModulesModel", QVariant::fromValue(m_settingsModules->items()));
    const QString qmlFile = m_package->filePath("mainscript");
    KUrl qurl = KUrl(m_package->filePath("mainscript"));
    QString packagePath = qurl.path().replace(qurl.fileName(), "");
    kDebug() << "FP: " << qurl.path().replace(qurl.fileName(), "");
    kDebug() << "QML File: " << qmlFile << packagePath;
    engine()->addImportPath(packagePath);

    setSource(QUrl(m_package->filePath("mainscript")));
    show();

    //QTimer::singleShot(4000, this, SLOT(updateStatus()));
    onStatusChanged(status());

    //connect(engine(), SIGNAL(signalHandlerException(QScriptValue)), this, SLOT(exception()));
    connect(this, SIGNAL(statusChanged(QDeclarativeView::Status)),
            this, SLOT(onStatusChanged(QDeclarativeView::Status)));
}

View::~View()
{
    delete m_package;
}

QObject* View::settings()
{
    return m_settings;
}

void View::updateStatus()
{
    onStatusChanged(status());
}

void View::onStatusChanged(QDeclarativeView::Status status)
{
    kDebug() << "onStatusChanged";
    if (status == QDeclarativeView::Ready) {
        if (!m_settingsRoot) {
            m_settingsRoot = rootObject()->findChild<QDeclarativeItem*>("settingsRoot");
            if (m_settingsRoot) {
                connect(m_settingsRoot, SIGNAL(loadPlugin(QString)),
                        this, SLOT(loadPlugin(QString)));
            } else {
                kError() << "settingsRoot component not found. :(";
            }
        }
    } else if (status == QDeclarativeView::Error) {
        foreach (const QDeclarativeError &e, errors()) {
            kDebug() << "EEEE" << e;
            kWarning() << "error in QML: " << e.toString() << e.description();
        }
    } else if (status == QDeclarativeView::Loading) {
        //kDebug() << "Loading.";
    }
}

void View::loadPlugin(const QString &pluginName)
{
    SettingsModuleLoader *loader = new SettingsModuleLoader(this);
    loader->loadPlugin(pluginName, rootContext());
}

#include "view.moc"
