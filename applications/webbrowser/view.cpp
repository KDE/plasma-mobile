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

#include <QDeclarativeContext>
#include <QDeclarativeEngine>
#include <QDeclarativeItem>
#include <QScriptValue>
#include <QGLWidget>

#include <KStandardDirs>
#include <KUriFilter>

#include "Plasma/Package"

#include <kdeclarative.h>

View::View(const QString &url, QWidget *parent)
    : QDeclarativeView(parent),
      m_options(new WebsiteOptions),
      m_webBrowser(0),
      m_urlInput(0),
      m_useGL(false)
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

    // Filter the supplied argument through KUriFilter and then
    // make the resulting url known to the webbrowser component
    // as startupArguments property
    QVariant a = QVariant(QStringList(filterUrl(url)));
    rootContext()->setContextProperty("startupArguments", a);

    // Locate the webbrowser QML component in the package
    // Note that this is a bit brittle, since it relies on the package name,
    // but it allows us to share the same code with the pure QML plasmoid
    // In a later stadium, we can install the QML stuff in a different path.
    QString qmlFile = KGlobal::dirs()->findResource("data",
                                    "plasma/plasmoids/qtwebbrowser/contents/code/webbrowser.qml");

    Plasma::PackageStructure::Ptr structure = Plasma::PackageStructure::load("Plasma/Generic");
    m_package = new Plasma::Package(QString(), "org.kde.active.webbrowser", structure);

    //kDebug() << "Loading QML File:" << qmlFile;
    setSource(QUrl(m_package->filePath("mainscript")));
    //kDebug() << "Plugin pathes:" << engine()->pluginPathList();
    show();
    rootContext()->setContextProperty("filteredUrl", QVariant(QString()));

    onStatusChanged(status());


    //connect(engine(), SIGNAL(signalHandlerException(QScriptValue)), this, SLOT(exception()));
    connect(this, SIGNAL(statusChanged(QDeclarativeView::Status)),
            this, SLOT(onStatusChanged(QDeclarativeView::Status)));
}

View::~View()
{
}

void View::setUseGL(const bool on)
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

bool View::useGL() const
{
    return m_useGL;
}

void View::onStatusChanged(QDeclarativeView::Status status)
{
    if (status == QDeclarativeView::Ready) {

        if (!m_webBrowser && !m_urlInput) {
            // Note that "webView" is defined as objectName in the QML file
            m_webBrowser = rootObject()->findChild<QDeclarativeItem*>("webView");
            if (m_webBrowser) {
                connect(m_webBrowser, SIGNAL(urlChanged()),
                        this, SLOT(urlChanged()));
                connect(m_webBrowser, SIGNAL(titleChanged()),
                        this, SLOT(onTitleChanged()));
            } else {
                kError() << "webView component not found. :(";
            }

            // Note that "urlInput" is defined as objectName in the QML file
            m_urlInput = rootObject()->findChild<QDeclarativeItem*>("urlInput");
            if (m_urlInput) {
                connect(m_urlInput, SIGNAL(urlEntered(const QString&)),
                        this, SLOT(onUrlEntered(const QString&)));
            } else {
                kError() << "urlInput component not found.";
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

void View::urlChanged()
{
    QVariant newUrl = m_webBrowser->property("url");
    m_options->url = newUrl.toString();
    // TODO: we could expose the URL to the activity here, but that's already done in QML
}

void View::onTitleChanged()
{
    if (m_webBrowser) {
        m_options->title = m_webBrowser->property("title").toString();
        //kDebug() << "Title changed to: " << m_options->title;
        emit titleChanged(m_options->title); // sets window caption
    }
}

QString View::filterUrl(const QString &url)
{
    QString filteredUrl(url);

    if (filteredUrl.indexOf('.') < 0) {
        //TODO: search engine config
        filteredUrl = "gg:"+filteredUrl;
    }

    filteredUrl = KUriFilter::self()->filteredUri(filteredUrl);

    return filteredUrl;
}

void View::onUrlEntered(const QString &newUrl)
{
    QString filteredUrl = filterUrl(newUrl);
    QDeclarativeItem *b = rootObject()->findChild<QDeclarativeItem*>("urlInput");
    if (b) {
        //kDebug() << "setting new property: filteredUrl : " << filteredUrl;
        b->setProperty("filteredUrl", QVariant(filteredUrl));
    }
}

#include "view.moc"
