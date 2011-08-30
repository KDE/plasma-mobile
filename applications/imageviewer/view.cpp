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

#include "view.h"
#include "dataenginebindings.h"

#include <QDeclarativeContext>
#include <QDeclarativeEngine>
#include <QDeclarativeItem>
#include <QScriptValue>
#include <QGLWidget>

#include <KStandardDirs>
#include <KDebug>

#include  <kdeclarative.h>

#include <Plasma/Corona>
#include <Plasma/Package>

AppView::AppView(const QString &url, QWidget *parent)
    : QDeclarativeView(parent),
      m_imageViewer(0),
      m_useGL(false)
{
    delete scene();
    setScene(new Plasma::Corona(this));
    setResizeMode(QDeclarativeView::SizeRootObjectToView);
    // Tell the script engine where to find the Plasma Quick components
    QStringList importPaths = KGlobal::dirs()->findDirs("lib", "kde4/imports");
    foreach (const QString &iPath, importPaths) {
        engine()->addImportPath(iPath);
    }

    KDeclarative kdeclarative;
    kdeclarative.setDeclarativeEngine(engine());
    kdeclarative.initialize();
    //binds things like kconfig and icons
    kdeclarative.setupBindings();
    QScriptEngine *scriptEngine = kdeclarative.scriptEngine();
    registerDataEngineMetaTypes(scriptEngine);

    // Filter the supplied argument through KUriFilter and then
    // make the resulting url known to the webbrowser component
    // as startupArguments property
    QVariant a = QVariant(QStringList(url));
    rootContext()->setContextProperty("startupArguments", a);

    Plasma::PackageStructure::Ptr structure = Plasma::PackageStructure::load("Plasma/Generic");
    m_package = new Plasma::Package(QString(), "org.kde.active.imageviewer", structure);

    //kDebug() << "Loading QML File:" << qmlFile;
    setSource(QUrl(m_package->filePath("mainscript")));
    //kDebug() << "Plugin pathes:" << engine()->pluginPathList();
    show();

    onStatusChanged(status());


    //connect(engine(), SIGNAL(signalHandlerException(QScriptValue)), this, SLOT(exception()));
    connect(this, SIGNAL(statusChanged(QDeclarativeView::Status)),
            this, SLOT(onStatusChanged(QDeclarativeView::Status)));
}

AppView::~AppView()
{
}

void AppView::setUseGL(const bool on)
{
#ifndef QT_NO_OPENGL
    if (on) {
      QGLWidget *glWidget = new QGLWidget;
      glWidget->setAutoFillBackground(false);
      setViewport(glWidget);
    }
#endif
    m_useGL = on;
}

bool AppView::useGL() const
{
    return m_useGL;
}

void AppView::onStatusChanged(QDeclarativeView::Status status)
{
    if (status == QDeclarativeView::Ready) {

        if (!m_imageViewer) {
            // Note that "webView" is defined as objectName in the QML file
            m_imageViewer = rootObject()->findChild<QDeclarativeItem*>("imageViewer");
            if (m_imageViewer) {
                connect(m_imageViewer, SIGNAL(titleChanged()),
                        this, SLOT(onTitleChanged()));
            } else {
                kError() << "imageViewer component not found.";
            }
        }
    } else if (status == QDeclarativeView::Error) {
        foreach (const QDeclarativeError &e, errors()) {
            kWarning() << "error in QML: " << e.toString() << e.description();
        }
    } else if (status == QDeclarativeView::Loading) { 
        //kDebug() << "Loading.";
    } 
}

#include "view.moc"
