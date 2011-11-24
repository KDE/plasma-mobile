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

#include <QDeclarativeContext>
#include <QDeclarativeEngine>
#include <QDeclarativeItem>
#include <QScriptValue>
#include <QGLWidget>
#include <QFile>

#include <KStandardDirs>
#include <KDebug>
#include <kdeversion.h>

#include <kdeclarative.h>

#include <Plasma/Package>

AppView::AppView(QWidget *parent)
    : QDeclarativeView(parent),
      m_rootItem(0),
      m_useGL(false)
{
    // avoid flicker on show
    setAttribute(Qt::WA_OpaquePaintEvent);
    setAttribute(Qt::WA_NoSystemBackground);
    viewport()->setAttribute(Qt::WA_OpaquePaintEvent);
    viewport()->setAttribute(Qt::WA_NoSystemBackground);

    setResizeMode(QDeclarativeView::SizeRootObjectToView);

    KDeclarative kdeclarative;
    kdeclarative.setDeclarativeEngine(engine());
    kdeclarative.initialize();
    //binds things like kconfig and icons
    kdeclarative.setupBindings();
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

    rootContext()->setContextProperty("runtimeInfoActiveVersion", "1.0");
    rootContext()->setContextProperty("runtimeInfoKdeVersion", KDE::versionString());
    rootContext()->setContextProperty("runtimeInfoOsVersion", osVersion);

    Plasma::PackageStructure::Ptr structure = Plasma::PackageStructure::load("Plasma/Generic");
    m_package = new Plasma::Package(QString(), "org.kde.active.aboutapp", structure);

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

        if (!m_rootItem) {
            // Note that "webView" is defined as objectName in the QML file
            m_rootItem = rootObject();

            if (m_rootItem) {
            } else {
                kError() << "aboutapp component not found.";
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
