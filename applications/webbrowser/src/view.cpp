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
#include "kdeclarativewebview.h"
#include "completionmodel.h"
#include "history.h"

#include <QDeclarativeContext>
#include <QDeclarativeEngine>
#include <QDeclarativeItem>
#include <QScriptValue>
#include <QGLWidget>
#include <QNetworkRequest>
#include <QDir>
#include <QGraphicsWebView>

#include <KStandardDirs>
#include <KUriFilter>
#include <KIO/AccessManager>
#include <KIO/Job>
#include <KIO/JobUiDelegate>

#include "Plasma/Package"

#include <kdeclarative.h>

View::View(const QString &url, QWidget *parent)
    : QDeclarativeView(parent),
      m_options(new WebsiteOptions),
      m_webBrowser(0),
      m_urlInput(0),
      m_useGL(false),
      m_completionModel(new CompletionModel(this))
{
    setResizeMode(QDeclarativeView::SizeRootObjectToView);

    KDeclarative kdeclarative;
    kdeclarative.setDeclarativeEngine(engine());
    kdeclarative.initialize();
    //binds things like kconfig and icons
    kdeclarative.setupBindings();

    // Filter the supplied argument through KUriFilter and then
    // make the resulting url known to the webbrowser component
    // as startupArguments property
    if (url.isEmpty()) {
        m_completionModel->populate();
    }
    QVariant a = QVariant(QStringList(filterUrl(url)));
    rootContext()->setContextProperty("startupArguments", a);
    rootContext()->setContextProperty("bookmarksModel", QVariant::fromValue(m_completionModel->filteredBookmarks()));
    rootContext()->setContextProperty("historyModel", QVariant::fromValue(m_completionModel->filteredHistory()));

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

    connect(m_completionModel, SIGNAL(dataChanged()), SLOT(setBookmarks()));
}

View::~View()
{
    m_completionModel->history()->saveHistory();
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

void View::setBookmarks()
{
    QDeclarativeItem* popup = rootObject()->findChild<QDeclarativeItem*>("completionPopup");
    if (popup) {
        //QList<QObject*> items = ;
        rootContext()->setContextProperty("bookmarksModel", QVariant::fromValue(m_completionModel->filteredBookmarks()));
        rootContext()->setContextProperty("historyModel", QVariant::fromValue(m_completionModel->filteredHistory()));
    }
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
                connect(m_webBrowser, SIGNAL(newWindowRequested(QString)),
                        this, SIGNAL(newWindow(QString)));
            } else {
                kError() << "webView component not found. :(";
            }

            // Note that "urlInput" is defined as objectName in the QML file
            m_urlInput = rootObject()->findChild<QDeclarativeItem*>("urlInput");
            if (m_urlInput) {
                connect(m_urlInput, SIGNAL(urlEntered(const QString&)),
                        this, SLOT(onUrlEntered(const QString&)));
                connect(m_urlInput, SIGNAL(urlFilterChanged()),
                        this, SLOT(urlFilterChanged()));
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
    QString newUrl = m_webBrowser->property("url").toString();
    QString newTitle = m_webBrowser->property("title").toString();
    m_options->url = newUrl;
}

void View::urlFilterChanged()
{
    QString newFilter = m_urlInput->property("urlFilter").toString();
    kDebug() << "Filtering completion" << newFilter;
    m_completionModel->populate();
    m_completionModel->setFilter(newFilter);
}

void View::onTitleChanged()
{
    if (m_webBrowser) {
        if (m_options->title == m_webBrowser->property("title").toString()) {
            return;
        }
        //kDebug() << "XXX title changed" << m_webBrowser->property("title").toString();
        m_options->title = m_webBrowser->property("title").toString();
        QString u = m_webBrowser->property("url").toString();
        m_completionModel->history()->visitPage(u, m_options->title);
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
