/*
    Copyright (C) 2009 Nokia Corporation and/or its subsidiary(-ies)

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Library General Public
    License as published by the Free Software Foundation; either
    version 2 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Library General Public License for more details.

    You should have received a copy of the GNU Library General Public License
    along with this library; see the file COPYING.LIB.  If not, write to
    the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
    Boston, MA 02110-1301, USA.
*/

#define QL1S(x)  QLatin1String(x)
#define QL1C(x)  QLatin1Char(x)

#include "kdeclarativewebview.h"
#include "networkaccessmanager.h"

#include <QtCore/QDebug>
#include <QtCore/QEvent>
#include <QtCore/QFile>
#include <QtDeclarative/QDeclarativeContext>
#include <QtDeclarative/QDeclarativeEngine>
#include <QtDeclarative/qdeclarative.h>
#include <QtGui/QApplication>
#include <QtGui/QGraphicsSceneMouseEvent>
#include <QtGui/QKeyEvent>
#include <QtGui/QMouseEvent>
#include <QtGui/QPen>
#include <QtNetwork/QNetworkReply>
#include <QtCore/QDir>
#include <QGraphicsScene>
#include <QGraphicsView>
#include <QPropertyAnimation>

#include <qwebelement.h>
#include <qwebframe.h>
#include <qwebpage.h>
#include <qwebsettings.h>

#include <KActivities/Info>
#include <KDirWatch>
#include <KFileDialog>
#include <KUrl>
#include <KGlobalSettings>
#include <KIO/Job>
#include <KIO/CopyJob>
#include <KIO/AccessManager>
#include <KIO/MetaData>
#include <KIO/JobUiDelegate>
#include <KStandardDirs>
#include <KWebWallet>
#include <KWindowSystem>
#include <KDebug>
#include <klocalizedstring.h>
#include <KMessageBox>

#include <soprano/vocabulary.h>
#include <Nepomuk2/Resource>
#include <Nepomuk2/Tag>
#include <Nepomuk2/Variant>

QT_BEGIN_NAMESPACE

class KDeclarativeWebViewPrivate {
public:
    KDeclarativeWebViewPrivate(KDeclarativeWebView* qq)
      : q(qq)
      , preferredwidth(0)
      , preferredheight(0)
      , progress(1.0)
      , status(KDeclarativeWebView::Null)
      , wallet(0)
      , pending(PendingNone)
      , newWindowComponent(0)
      , newWindowParent(0)
      , rendering(true)
    {
    }

    KDeclarativeWebView* q;

    QUrl url; // page url might be different if it has not loaded yet
    GraphicsWebView* view;

    int preferredwidth, preferredheight;
    qreal progress;
    KDeclarativeWebView::Status status;
    KWebWallet *wallet;
    QString statusText;
    enum { PendingNone, PendingUrl, PendingHtml, PendingContent } pending;
    QUrl pendingUrl;
    QString pendingString;
    QByteArray pendingData;
    QStringList rssFeeds;
    mutable KDeclarativeWebSettings settings;
    QDeclarativeComponent* newWindowComponent;
    QDeclarativeItem* newWindowParent;

    static void windowObjectsAppend(QDeclarativeListProperty<QObject>* prop, QObject* o)
    {
        static_cast<KDeclarativeWebViewPrivate*>(prop->data)->windowObjects.append(o);
        static_cast<KDeclarativeWebViewPrivate*>(prop->data)->updateWindowObjects();
    }

    void updateWindowObjects();
    QObjectList windowObjects;

    bool rendering;

    KDirWatch* dirWatch;
};

GraphicsWebView::GraphicsWebView(KDeclarativeWebView* parent)
    : QGraphicsWebView(parent)
    , parent(parent)
    , pressTime(400)
    , flicking(true)
{
    m_posAnim = new QPropertyAnimation(this);
    m_posAnim->setDuration(250);
    m_posAnim->setEasingCurve(QEasingCurve::InOutQuad);
    m_posAnim->setTargetObject(this);
    m_posAnim->setPropertyName("pos");
    m_posAnim->setEndValue(QPoint(0, 0));
}

void GraphicsWebView::mousePressEvent(QGraphicsSceneMouseEvent* event)
{
    pressPoint = event->pos();
    if (pressTime) {
        pressTimer.start(pressTime, this);
        parent->setKeepMouseGrab(false);
    } else {
        //emit pressandhold events anyways, but not setKeepMouseGrab
        pressTimer.start(400, this);
        grabMouse();
        parent->setKeepMouseGrab(true);
    }
    pressTimer.start(pressTime, this);
    QGraphicsWebView::mousePressEvent(event);

    QWebHitTestResult hit = page()->mainFrame()->hitTestContent(pressPoint.toPoint());
    if (hit.isContentEditable()) {
        parent->forceActiveFocus();
    }
    // Comboboxes and flicking don't go together well,
    // disable flicking as long as the combo box is open
    setFlickingEnabled(hit.element().tagName() != "SELECT");

    kDebug() << " - - >  Hit element: " << hit.element().tagName() << hit.element().geometry() << hit.linkElement().geometry();

    if (!hit.linkElement().geometry().isNull()) {
        kDebug() << "XXXXXXXXXX link pressed. .. ";
        emit linkPressed(hit.linkUrl(), hit.linkElement().geometry());
    }
    //QMouseEvent* me = new QMouseEvent(QEvent::MouseButtonDblClick, (event->pos() / parent->contentsScale()).toPoint(), event->button(), event->buttons(), 0);
    emit click(event->pos().x(), event->pos().y());
    setFocus();
}

void GraphicsWebView::mouseReleaseEvent(QGraphicsSceneMouseEvent* event)
{
    if (pressTime == 0 || pressTimer.isActive()) {
        QGraphicsWebView::mouseReleaseEvent(event);
    }

    pressTimer.stop();
    parent->setKeepMouseGrab(false);
    ungrabMouse();

    if (pos() != QPoint(0, 0)) {
        m_posAnim->start();
    }
}

void GraphicsWebView::mouseDoubleClickEvent(QGraphicsSceneMouseEvent* event)
{
    QMouseEvent* me = new QMouseEvent(QEvent::MouseButtonDblClick, (event->pos() / parent->contentsScale()).toPoint(), event->button(), event->buttons(), 0);
    emit doubleClick(event->pos().x(), event->pos().y());
    delete me;
}

void GraphicsWebView::handleLinkClicked(const QUrl &link)
{
    QUrl u(link);
    if (pressTime == 0 || pressTimer.isActive()) {
        kDebug() << "timer is running, loading URL" << link;
        page()->mainFrame()->load(u);
    } else {
        kDebug() << "timer is not running, not loading url" << link;
    }
}

void GraphicsWebView::timerEvent(QTimerEvent* event)
{
    if (event->timerId() == pressTimer.timerId()) {
        pressTimer.stop();
        if (pressTime) {
            grabMouse();
            parent->setKeepMouseGrab(true);
        }
        kDebug() << "handle pressAndHold";
        QWebHitTestResult hit = page()->mainFrame()->hitTestContent(pressPoint.toPoint());
        if (!hit.linkElement().geometry().isNull()) {
            kDebug() << "Link pressed and hold";
            emit linkPressAndHold(hit.linkUrl(), hit.linkElement().geometry());

        } else if (!page()->selectedText().isEmpty()) {
            kDebug() << "Selection press and hold";
            emit selectionPressAndHold(page()->selectedText(), pressPoint.toPoint());
        }
    }
}

void GraphicsWebView::mouseMoveEvent(QGraphicsSceneMouseEvent* event)
{
    if (pressTimer.isActive()) {
        if ((event->pos() - pressPoint).manhattanLength() > QApplication::startDragDistance())
            pressTimer.stop();
    }

    if (parent->keepMouseGrab()) {
        QGraphicsWebView::mouseMoveEvent(event);
    } else if (flicking) {
        QPoint deltaMousePos = QPointF(event->lastScenePos() - event->scenePos()).toPoint();
        QPoint finalPos = pos().toPoint();

        if (pos().x() > 0) {
            finalPos.rx() = qMax(0, (int)(pos().x() - deltaMousePos.x()));
            deltaMousePos.rx() = 0;
        } else if  (pos().x() < 0) {
            finalPos.rx() = qMin(0, (int)(pos().x() - deltaMousePos.x()));
            deltaMousePos.rx() = 0;
        }

        if (pos().y() > 0) {
            finalPos.ry() = qMax(0, (int)(pos().y() - deltaMousePos.y()));
            deltaMousePos.ry() = 0;
        } else if  (pos().y() < 0) {
            finalPos.ry() = qMin(0, (int)(pos().y() - deltaMousePos.y()));
            deltaMousePos.ry() = 0;
        }

        if (deltaMousePos != QPoint(0, 0) && !parent->scrollBy(deltaMousePos.x(), deltaMousePos.y(), event->pos())) {
            if (page()->mainFrame()->contentsSize().width() <= size().width()) {
                deltaMousePos.rx() = 0;
            }
            if (page()->mainFrame()->contentsSize().height() <= size().height()) {
                deltaMousePos.ry() = 0;
            }
            finalPos = pos().toPoint() - deltaMousePos;
        }
        setPos(finalPos);
    }
}

bool GraphicsWebView::sceneEvent(QEvent *event)
{
    bool rv = QGraphicsWebView::sceneEvent(event);
    if (event->type() == QEvent::UngrabMouse) {
        pressTimer.stop();
        parent->setKeepMouseGrab(false);
    }
    return rv;
}

bool GraphicsWebView::flickingEnabled() const
{
    return flicking;
}

void GraphicsWebView::setFlickingEnabled(bool enabled)
{
    if (flicking != enabled) {
        flicking = enabled;
        emit flickingEnabledChanged();
    }
}

/*!
    \qmlclass WebView KDeclarativeWebView
    \ingroup qml-view-elements
    \since 4.7
    \brief The WebView item allows you to add Web content to a canvas.
    \inherits Item

    A WebView renders Web content based on a URL.

    This type is made available by importing the \c QtWebKit module:

    \bold{import QtWebKit 1.0}

    The WebView item includes no scrolling, scaling, toolbars, or other common browser
    components. These must be implemented around WebView. See the \l{QML Web Browser}
    example for a demonstration of this.

    The page to be displayed by the item is specified using the \l url property,
    and this can be changed to fetch and display a new page. While the page loads,
    the \l progress property is updated to indicate how much of the page has been
    loaded.

    \section1 Appearance

    If the width and height of the item is not set, they will dynamically adjust
    to a size appropriate for the content. This width may be large for typical
    online web pages, typically greater than 800 by 600 pixels.

    If the \l{Item::}{width} or \l{Item::}{height} is explictly set, the rendered Web site will be
    clipped, not scaled, to fit into the set dimensions.

    If the preferredWidth property is set, the width will be this amount or larger,
    usually laying out the Web content to fit the preferredWidth.

    The appearance of the content can be controlled to a certain extent by changing
    the settings.standardFontFamily property and other settings related to fonts.

    The page can be zoomed by calling the heuristicZoom() method, which performs a
    series of tests to determine whether zoomed content will be displayed in an
    appropriate way in the space allocated to the item.

    \section1 User Interaction and Navigation

    By default, certain mouse and touch events are delivered to other items in
    preference to the Web content. For example, when a scrolling view is created
    by placing a WebView in a Flickable, move events are delivered to the Flickable
    so that the user can scroll the page. This prevents the user from accidentally
    selecting text in a Web page instead of scrolling.

    The pressGrabTime property defines the time the user must touch or press a
    mouse button over the WebView before the Web content will receive the move
    events it needs to select text and images.

    When this item has keyboard focus, all keyboard input will be sent directly to
    the Web page within.

    When the navigates by clicking on links, the item records the pages visited
    in its internal history

    Because this item is designed to be used as a component in a browser, it
    exposes \l{Action}{actions} for \l back, \l forward, \l reload and \l stop.
    These can be triggered to change the current page displayed by the item.

    \section1 Example Usage

    \beginfloatright
    \inlineimage webview.png
    \endfloat

    The following example displays a scaled down Web page at a fixed size.

    \snippet doc/src/snippets/declarative/webview/webview.qml document

    \clearfloat

    \sa {declarative/modelviews/webview}{WebView example}, {demos/declarative/webbrowser}{Web Browser demo}
*/

/*!
    \internal
    \class KDeclarativeWebView
    \brief The KDeclarativeWebView class allows you to add web content to a QDeclarativeView.

    A WebView renders web content base on a URL.

    \image webview.png

    The item includes no scrolling, scaling,
    toolbars, etc., those must be implemented around WebView. See the WebBrowser example
    for a demonstration of this.

    A KDeclarativeWebView object can be instantiated in Qml using the tag \l WebView.
*/

KDeclarativeWebView::KDeclarativeWebView(QDeclarativeItem *parent)
    : QDeclarativeItem(parent),
      m_preferMobile(false)
{
    init();
}

KDeclarativeWebView::~KDeclarativeWebView()
{
    delete d;
}

void KDeclarativeWebView::init()
{
    d = new KDeclarativeWebViewPrivate(this);

    if (QWebSettings::iconDatabasePath().isNull() &&
        QWebSettings::globalSettings()->localStoragePath().isNull() &&
        QWebSettings::offlineStoragePath().isNull() &&
        QWebSettings::offlineWebApplicationCachePath().isNull()) 
        QWebSettings::enablePersistentStorage();

    setAcceptedMouseButtons(Qt::LeftButton);
    setFlag(QGraphicsItem::ItemHasNoContents, true);
    setClip(true);

    d->view = new GraphicsWebView(this);
    connect(d->view, SIGNAL(xChanged()), this, SIGNAL(overShootXChanged()));
    connect(d->view, SIGNAL(yChanged()), this, SIGNAL(overShootYChanged()));
    connect(d->view->page(), SIGNAL(selectionChanged()), this, SIGNAL(selectedTextChanged()));

    //d->view->setResizesToContents(true);
    QWebPage* wp = new QDeclarativeWebPage(this);
    KWebPage* kwp = qobject_cast<KWebPage*>(wp);

    if (kwp) {
        WId wid = KWindowSystem::activeWindow();
        d->wallet = new KWebWallet(this, wid);
        kwp->setWallet(d->wallet);
        // TODO: hook in some dialog whether the user wants to save the form data
        // happens unconditionally right now for every form filled in
        connect(d->wallet, SIGNAL(saveFormDataRequested(QString,QUrl)),
            d->wallet, SLOT(acceptSaveFormDataRequest(QString)), Qt::UniqueConnection);
    }

    wp->setForwardUnsupportedContent(true);

    setPage(wp);
    initSettings();
#ifndef NO_KIO
    NetworkAccessManager *access = new NetworkAccessManager(page());
    // set network reply object to emit readyRead when it receives meta data
    access->setEmitReadyReadOnMetaDataChange(true);

    // disable QtWebKit cache to just use KIO one..
    access->setCache(0);

    // set cookieJar window..
    /*if (parent && parent->window())
        manager->setWindow(parent->window());*/

    //FIXME: make this thing reliable
    if (QApplication::topLevelWidgets().length() > 0) {
        access->setWindow(QApplication::topLevelWidgets().first());
    }
    wp->setNetworkAccessManager(access);
#endif

    connect(d->view, SIGNAL(geometryChanged()), this, SLOT(updateDeclarativeWebViewSize()));
    connect(d->view, SIGNAL(flickingEnabledChanged()), this, SLOT(updateFlickingEnabled()));
    connect(d->view, SIGNAL(click(int,int)), this, SIGNAL(click(int,int)));
    connect(d->view, SIGNAL(doubleClick(int,int)), this, SIGNAL(doubleClick(int,int)));
    
    //connect(d->view, SIGNAL(loadLink(QUrl,QRect)), SIGNAL(linkClicked(QUrl,QRect)));
    connect(d->view, SIGNAL(linkPressed(QUrl,QRect)),
            this, SIGNAL(linkPressed(QUrl,QRect)));
    connect(d->view, SIGNAL(linkPressAndHold(QUrl,QRect)),
            this, SIGNAL(linkPressAndHold(QUrl,QRect)));
    connect(d->view, SIGNAL(selectionPressAndHold(QString, QPoint)),
            this, SIGNAL(selectionPressAndHold(QString, QPoint)));
    connect(d->view, SIGNAL(scaleChanged()), this, SIGNAL(contentsScaleChanged()));

    connect(access, SIGNAL(finished(QNetworkReply*)), page(), SLOT(handleNetworkErrors(QNetworkReply*)));

    wp->setLinkDelegationPolicy(QWebPage::DelegateAllLinks);
    connect(wp, SIGNAL(linkClicked(QUrl)), d->view, SLOT(handleLinkClicked(QUrl)));


    connect(this, SIGNAL(scrollRequested(int, int, QRect)), this, SIGNAL(contentsPositionChanged()));
    d->dirWatch = new KDirWatch(this);
    QString configPath = KStandardDirs::locateLocal("config", "active-webbrowserrc");
    d->dirWatch->addFile(configPath);
    connect(d->dirWatch, SIGNAL(dirty(QString)), SLOT(initSettings()));
    connect(d->dirWatch, SIGNAL(created(QString)), SLOT(initSettings()));
}

QPointF KDeclarativeWebView::contentsPosition()
{
    return d->view->page()->mainFrame()->scrollPosition();
}

void KDeclarativeWebView::setContentsPosition(QPointF contentsPosition)
{
    const QPoint oldPos = d->view->page()->mainFrame()->scrollPosition();

    d->view->page()->mainFrame()->setScrollPosition(contentsPosition.toPoint());

    if (oldPos.x() != d->view->page()->mainFrame()->scrollPosition().x()) {
        emit contentXChanged(d->view->page()->mainFrame()->scrollPosition().x());
    }
    if (oldPos.y() != d->view->page()->mainFrame()->scrollPosition().y()) {
        emit contentYChanged(d->view->page()->mainFrame()->scrollPosition().y());
    }

    if (oldPos.x() != d->view->page()->mainFrame()->scrollPosition().x() ||
        oldPos.y() != d->view->page()->mainFrame()->scrollPosition().y()) {
        emit contentsPositionChanged();
    }
}

int KDeclarativeWebView::contentX() const
{
    return d->view->page()->mainFrame()->scrollPosition().x();
}

void KDeclarativeWebView::setContentX(int contentX)
{
    const QPoint oldPos = d->view->page()->mainFrame()->scrollPosition();
    if (oldPos.x() == contentX) {
        return;
    }

    d->view->page()->mainFrame()->setScrollPosition(QPoint(contentX, d->view->page()->mainFrame()->scrollPosition().y()));

    if (oldPos.x() == d->view->page()->mainFrame()->scrollPosition().x()) {
        return;
    }

    emit contentXChanged(d->view->page()->mainFrame()->scrollPosition().x());
    emit contentsPositionChanged();
}


int KDeclarativeWebView::contentY() const
{
    return d->view->page()->mainFrame()->scrollPosition().y();
}

void KDeclarativeWebView::setContentY(int contentY)
{
    const QPoint oldPos = d->view->page()->mainFrame()->scrollPosition();
    if (oldPos.y() == contentY) {
        return;
    }

    d->view->page()->mainFrame()->setScrollPosition(QPoint(d->view->page()->mainFrame()->scrollPosition().x(), contentY));

    if (oldPos.y() == d->view->page()->mainFrame()->scrollPosition().y()) {
        return;
    }

    emit contentYChanged(d->view->page()->mainFrame()->scrollPosition().y());
    emit contentsPositionChanged();
}


int KDeclarativeWebView::overShootX() const
{
    return d->view->pos().x();
}

int KDeclarativeWebView::overShootY() const
{
    return d->view->pos().y();
}


bool KDeclarativeWebView::preferMobile() const
{
    return m_preferMobile;
}

void KDeclarativeWebView::initSettings()
{
    // From configuration
    KSharedConfigPtr ptr = KSharedConfig::openConfig("active-webbrowserrc");
    ptr->reparseConfiguration();
    KConfigGroup cg(ptr, "webbrowser");

    // WebKit renders the fonts too small, so we add a few points to make them readable
    const int fontSizeCorrection = cg.readEntry("fontSizeCorrection", 0) + 4;
//     kDebug() << "Font size correction is: " << fontSizeCorrection;
    //kDebug() << "Settings up fonts and reading settings: " << KGlobalSettings::generalFont().family() << KGlobalSettings::generalFont().pointSize();
    settings()->setFontFamily(QWebSettings::StandardFont,  KGlobalSettings::generalFont().family());
    settings()->setFontFamily(QWebSettings::SerifFont,  KGlobalSettings::generalFont().family());
    settings()->setFontFamily(QWebSettings::FixedFont,  KGlobalSettings::generalFont().family());
    settings()->setFontFamily(QWebSettings::CursiveFont,  KGlobalSettings::generalFont().family());
    settings()->setFontFamily(QWebSettings::SansSerifFont,  KGlobalSettings::generalFont().family());
    settings()->setFontFamily(QWebSettings::FantasyFont,  KGlobalSettings::generalFont().family());

    //const int fontSizeCorrection = 4;
    settings()->setFontSize(QWebSettings::DefaultFontSize,  KGlobalSettings::generalFont().pointSize()+fontSizeCorrection);
    //settings()->setFontSize(QWebSettings::FontSize, KGlobalSettings::generalFont().pointSize()+fontSizeCorrection);
    settings()->setFontSize(QWebSettings::DefaultFixedFontSize,  KGlobalSettings::fixedFont().pointSize()+fontSizeCorrection);
    settings()->setFontSize(QWebSettings::MinimumFontSize,  KGlobalSettings::smallestReadableFont().pointSize()+fontSizeCorrection);
    settings()->setFontSize(QWebSettings::MinimumLogicalFontSize,  KGlobalSettings::smallestReadableFont().pointSize()+fontSizeCorrection);
    //     kDebug() << "Fonts: ===========" << KGlobalSettings::generalFont().pixelSize() << KGlobalSettings::generalFont().pointSize();

    bool pluginsEnabled = cg.readEntry("pluginsEnabled", false);
    //kDebug() << " C++ Plugins on? " << pluginsEnabled;

    settings()->setAttribute(QWebSettings::PluginsEnabled, pluginsEnabled);
    settingsObject()->setPluginsEnabled(pluginsEnabled);

    m_preferMobile = cg.readEntry("preferMobile", false);
}

void KDeclarativeWebView::componentComplete()
{
    QDeclarativeItem::componentComplete();
#ifdef NO_KIO
    page()->setNetworkAccessManager(qmlEngine(this)->networkAccessManager());
#endif

    switch (d->pending) {
    case KDeclarativeWebViewPrivate::PendingUrl:
        setUrl(d->pendingUrl);
        break;
    case KDeclarativeWebViewPrivate::PendingHtml:
        setHtml(d->pendingString, d->pendingUrl);
        break;
    case KDeclarativeWebViewPrivate::PendingContent:
        setContent(d->pendingData, d->pendingString, d->pendingUrl);
        break;
    default:
        break;
    }
    d->pending = KDeclarativeWebViewPrivate::PendingNone;
    d->updateWindowObjects();
}

KDeclarativeWebView::Status KDeclarativeWebView::status() const
{
    return d->status;
}


/*!
    \qmlproperty real WebView::progress
    This property holds the progress of loading the current URL, from 0 to 1.

    If you just want to know when progress gets to 1, use
    WebView::onLoadFinished() or WebView::onLoadFailed() instead.
*/
qreal KDeclarativeWebView::progress() const
{
    return d->progress;
}

void KDeclarativeWebView::doLoadStarted()
{
    if (!d->url.isEmpty()) {
        d->status = Loading;
        emit statusChanged(d->status);
    }
    setRssFeeds(QStringList());
    emit loadStarted();
}

void KDeclarativeWebView::doLoadProgress(int p)
{
    if (d->progress == p / 100.0)
        return;
    d->progress = p / 100.0;
    emit progressChanged();
}

void KDeclarativeWebView::pageUrlChanged()
{
    updateContentsSize();

    if ((d->url.isEmpty() && page()->mainFrame()->url() != QUrl(QLatin1String("about:blank")))
        || (d->url != page()->mainFrame()->url() && !page()->mainFrame()->url().isEmpty()))
    {
        d->url = page()->mainFrame()->url();
        if (d->url == QUrl(QLatin1String("about:blank")))
            d->url = QUrl();
        emit urlChanged();
    }
}

void KDeclarativeWebView::doLoadFinished(bool ok)
{
    if (ok) {
        d->status = d->url.isEmpty() ? Null : Ready;
        emit loadFinished();
        if (d->status == Ready) {
            if (d->wallet) {
                d->wallet->fillFormData(page()->mainFrame());
            }

            foreach (const QWebElement &el, page()->mainFrame()->findAllElements("LINK")) {
                if (el.attribute("type").contains("application/rss+xml")) {
                    d->rssFeeds << el.attribute("href");
                }
            }
            if (!rssFeeds().isEmpty()) {
                emit rssFeedsChanged();
            }
        }
    } else {
        d->status = Error;
        emit loadFailed();
    }
    emit statusChanged(d->status);
}

/*!
    \qmlproperty url WebView::url
    This property holds the URL to the page displayed in this item. It can be set,
    but also can change spontaneously (eg. because of network redirection).

    If the url is empty, the page is blank.

    The url is always absolute (QML will resolve relative URL strings in the context
    of the containing QML document).
*/
QUrl KDeclarativeWebView::url() const
{
    return d->url;
}

void KDeclarativeWebView::setUrl(const QUrl& url)
{
    if (url == d->url)
        return;

    if (isComponentComplete()) {
        d->url = url;
        updateContentsSize();
        QUrl seturl = url;
        if (seturl.isEmpty())
            seturl = QUrl(QLatin1String("about:blank"));

        Q_ASSERT(!seturl.isRelative());

        page()->mainFrame()->load(seturl);

        emit urlChanged();
    } else {
        d->pending = d->PendingUrl;
        d->pendingUrl = url;
    }
}

QStringList KDeclarativeWebView::rssFeeds() const
{
    return d->rssFeeds;
}

void KDeclarativeWebView::setRssFeeds(const QStringList &feeds)
{
    if (d->rssFeeds != feeds) {
        d->rssFeeds = feeds;
        emit rssFeedsChanged();
    };
}

/*!
    \qmlproperty int WebView::preferredWidth
    This property holds the ideal width for displaying the current URL.
*/
int KDeclarativeWebView::preferredWidth() const
{
    return d->preferredwidth;
}

void KDeclarativeWebView::setPreferredWidth(int width)
{
    if (d->preferredwidth == width)
        return;
    d->preferredwidth = width;
    updateContentsSize();
    emit preferredWidthChanged();
}

/*!
    \qmlproperty int WebView::preferredHeight
    This property holds the ideal height for displaying the current URL.
    This only affects the area zoomed by heuristicZoom().
*/
int KDeclarativeWebView::preferredHeight() const
{
    return d->preferredheight;
}

bool KDeclarativeWebView::scrollBy(int dx, int dy, const QPointF& pos)
{
    QPoint oldContentsPos = contentsPosition().toPoint();

    QWebFrame *frame = page()->frameAt(pos.toPoint());
    if (!frame) {
        frame = page()->mainFrame();
    }
    
    if (qtwebkit_webframe_scrollOverflow(frame, dx, dy, pos.toPoint())) {
        return true;
    }

    if (!frame) {
        return false;
    }

    bool scrollHorizontal = false;
    bool scrollVertical = false;

    do {
        if (dx > 0)  // scroll right
            scrollHorizontal = frame->scrollPosition().x() < frame->contentsSize().width() - width();
        else if (dx < 0)  // scroll left
            scrollHorizontal = frame->scrollPosition().x() > 0;

        if (dy > 0)  // scroll down
            scrollVertical = frame->scrollPosition().y() < frame->contentsSize().height() - height();
        else if (dy < 0) //scroll up
            scrollVertical = frame->scrollPosition().y() > 0;

        if (scrollHorizontal || scrollVertical) {
            frame->scroll(dx, dy);
            if (scrollHorizontal) {
                emit contentXChanged(frame->scrollPosition().x());
            }
            if (scrollVertical) {
                emit contentYChanged(frame->scrollPosition().y());
            }
            
            emit contentsPositionChanged();
            return true;
        }

        frame = frame->parentFrame();
    } while (frame);

    return false;
}

void KDeclarativeWebView::setPreferredHeight(int height)
{
    if (d->preferredheight == height)
        return;
    d->preferredheight = height;
    updateContentsSize();
    emit preferredHeightChanged();
}

/*!
    \qmlmethod bool WebView::evaluateJavaScript(string scriptSource)

    Evaluates the \a scriptSource JavaScript inside the context of the
    main web frame, and returns the result of the last executed statement.

    Note that this JavaScript does \e not have any access to QML objects
    except as made available as windowObjects.
*/
QVariant KDeclarativeWebView::evaluateJavaScript(const QString& scriptSource)
{
    return this->page()->mainFrame()->evaluateJavaScript(scriptSource);
}

void KDeclarativeWebView::updateDeclarativeWebViewSize()
{
    QSizeF size = d->view->geometry().size() * contentsScale();
    setImplicitWidth(size.width());
    setImplicitHeight(size.height());
}

void KDeclarativeWebView::initialLayout()
{
    // nothing useful to do at this point
}

void KDeclarativeWebView::updateContentsSize()
{
    if (page()) {
        page()->setPreferredContentsSize(QSize(
            d->preferredwidth>0 ? d->preferredwidth : width(),
            d->preferredheight>0 ? d->preferredheight : height()));
    }
}

void KDeclarativeWebView::geometryChanged(const QRectF& newGeometry, const QRectF& oldGeometry)
{
    QWebPage* webPage = page();
    if (newGeometry.size() != oldGeometry.size() && webPage) {
        QSize contentSize = webPage->preferredContentsSize();
        if (widthValid())
            contentSize.setWidth(width());
        if (heightValid())
            contentSize.setHeight(height());
        d->view->resize(contentSize);
        if (contentSize != webPage->preferredContentsSize())
            webPage->setPreferredContentsSize(contentSize);
    }
    QDeclarativeItem::geometryChanged(newGeometry, oldGeometry);
}

/*!
    \qmlproperty list<object> WebView::javaScriptWindowObjects

    A list of QML objects to expose to the web page.

    Each object will be added as a property of the web frame's window object.  The
    property name is controlled by the value of \c WebView.windowObjectName
    attached property.

    Exposing QML objects to a web page allows JavaScript executing in the web
    page itself to communicate with QML, by reading and writing properties and
    by calling methods of the exposed QML objects.

    This example shows how to call into a QML method using a window object.

    \qml
    WebView {
        javaScriptWindowObjects: QtObject {
            WebView.windowObjectName: "qml"

            function qmlCall() {
                console.log("This call is in QML!");
            }
        }

        html: "<script>console.log(\"This is in WebKit!\"); window.qml.qmlCall();</script>"
    }
    \endqml

    The output of the example will be:
    \code
    This is in WebKit!
    This call is in QML!
    \endcode

    If Javascript is not enabled for the page, then this property does nothing.
*/
QDeclarativeListProperty<QObject> KDeclarativeWebView::javaScriptWindowObjects()
{
    return QDeclarativeListProperty<QObject>(this, d, &KDeclarativeWebViewPrivate::windowObjectsAppend);
}

KDeclarativeWebViewAttached* KDeclarativeWebView::qmlAttachedProperties(QObject* o)
{
    return new KDeclarativeWebViewAttached(o);
}

void KDeclarativeWebViewPrivate::updateWindowObjects()
{
    if (!q->isComponentCompletePublic() || !q->page())
        return;

    for (int i = 0; i < windowObjects.count(); ++i) {
        QObject* object = windowObjects.at(i);
        KDeclarativeWebViewAttached* attached = static_cast<KDeclarativeWebViewAttached *>(qmlAttachedPropertiesObject<KDeclarativeWebView>(object));
        if (attached && !attached->windowObjectName().isEmpty())
            q->page()->mainFrame()->addToJavaScriptWindowObject(attached->windowObjectName(), object);
    }
}

bool KDeclarativeWebView::renderingEnabled() const
{
    return d->rendering;
}

void KDeclarativeWebView::setRenderingEnabled(bool enabled)
{
    if (d->rendering == enabled)
        return;
    d->rendering = enabled;
    emit renderingEnabledChanged();
    d->view->setTiledBackingStoreFrozen(!enabled);

    if (enabled) {
        d->view->page()->mainFrame()->setZoomFactor(d->view->scale());
        d->view->setScale(1);
    } else {
        d->view->setScale(d->view->page()->mainFrame()->zoomFactor());
        d->view->page()->mainFrame()->setZoomFactor(1);
    }
}

QString KDeclarativeWebView::selectedText() const
{
    return page()->selectedText();
}

/*!
    \qmlsignal WebView::onDoubleClick(int clickx, int clicky)

    The WebView does not pass double-click events to the web engine, but rather
    emits this signals.
*/

/*!
    \qmlmethod bool WebView::heuristicZoom(int clickX, int clickY, real maxzoom)

    Finds a zoom that:
    \list
    \i shows a whole item
    \i includes (\a clickX, \a clickY)
    \i fits into the preferredWidth and preferredHeight
    \i zooms by no more than \a maxZoom
    \i is more than 10% above the current zoom
    \endlist

    If such a zoom exists, emits zoomTo(zoom,centerX,centerY) and returns true; otherwise,
    no signal is emitted and returns false.
*/
bool KDeclarativeWebView::heuristicZoom(int clickX, int clickY, qreal maxZoom)
{
    if (contentsScale() >= maxZoom / scale())
        return false;
    qreal ozf = contentsScale();
    QRect showArea = elementAreaAt(clickX, clickY, d->preferredwidth / maxZoom, d->preferredheight / maxZoom);
    qreal z = qMin(qreal(d->preferredwidth) / showArea.width(), qreal(d->preferredheight) / showArea.height());
    if (z > maxZoom / scale())
        z = maxZoom / scale();
    if (z / ozf > 1.2) {
        QRectF r(showArea.left() * z, showArea.top() * z, showArea.width() * z, showArea.height() * z);
        emit zoomTo(z, r.x() + r.width() / 2, r.y() + r.height() / 2);
        return true;
    }
    return false;
}

/*!
    \qmlproperty int WebView::pressGrabTime

    The number of milliseconds the user must press before the WebView
    starts passing move events through to the Web engine (rather than
    letting other QML elements such as a Flickable take them).

    Defaults to 400ms. Set to 0 to always grab and pass move events to
    the Web engine.
*/
int KDeclarativeWebView::pressGrabTime() const
{
    return d->view->pressTime;
}

void KDeclarativeWebView::setPressGrabTime(int millis)
{
    if (d->view->pressTime == millis)
        return;
    d->view->pressTime = millis;
    emit pressGrabTimeChanged();
}

bool KDeclarativeWebView::flickingEnabled() const
{
    return d->view->flickingEnabled();
}

void KDeclarativeWebView::setFlickingEnabled(bool enabled)
{
    d->view->setFlickingEnabled(enabled);
    emit flickingEnabledChanged();
}

void KDeclarativeWebView::updateFlickingEnabled()
{
    setFlickingEnabled(d->view->flickingEnabled());
}

#ifndef QT_NO_ACTION
/*!
    \qmlproperty action WebView::back
    This property holds the action for causing the previous URL in the history to be displayed.
*/
QAction* KDeclarativeWebView::backAction() const
{
    return page()->action(QWebPage::Back);
}

/*!
    \qmlproperty action WebView::forward
    This property holds the action for causing the next URL in the history to be displayed.
*/
QAction* KDeclarativeWebView::forwardAction() const
{
    return page()->action(QWebPage::Forward);
}

/*!
    \qmlproperty action WebView::reload
    This property holds the action for reloading with the current URL
*/
QAction* KDeclarativeWebView::reloadAction() const
{
    return page()->action(QWebPage::Reload);
}

/*!
    \qmlproperty action WebView::stop
    This property holds the action for stopping loading with the current URL
*/
QAction* KDeclarativeWebView::stopAction() const
{
    return page()->action(QWebPage::Stop);
}
#endif // QT_NO_ACTION

/*!
    \qmlproperty string WebView::title
    This property holds the title of the web page currently viewed

    By default, this property contains an empty string.
*/
QString KDeclarativeWebView::title() const
{
    return page()->mainFrame()->title();
}

/*!
    \qmlproperty pixmap WebView::icon
    This property holds the icon associated with the web page currently viewed
*/
QPixmap KDeclarativeWebView::icon() const
{
    return page()->mainFrame()->icon().pixmap(QSize(256, 256));
}

/*!
    \qmlproperty string WebView::statusText

    This property is the current status suggested by the current web page. In a web browser,
    such status is often shown in some kind of status bar.
*/
void KDeclarativeWebView::setStatusText(const QString& text)
{
    d->statusText = text;
    emit statusTextChanged();
}

void KDeclarativeWebView::windowObjectCleared()
{
    d->updateWindowObjects();
}

QString KDeclarativeWebView::statusText() const
{
    return d->statusText;
}

QWebPage* KDeclarativeWebView::page() const
{
    return d->view->page();
}

// The QObject interface to settings().
/*!
    \qmlproperty string WebView::settings.standardFontFamily
    \qmlproperty string WebView::settings.fixedFontFamily
    \qmlproperty string WebView::settings.serifFontFamily
    \qmlproperty string WebView::settings.sansSerifFontFamily
    \qmlproperty string WebView::settings.cursiveFontFamily
    \qmlproperty string WebView::settings.fantasyFontFamily

    \qmlproperty int WebView::settings.minimumFontSize
    \qmlproperty int WebView::settings.minimumLogicalFontSize
    \qmlproperty int WebView::settings.defaultFontSize
    \qmlproperty int WebView::settings.defaultFixedFontSize

    \qmlproperty bool WebView::settings.autoLoadImages
    \qmlproperty bool WebView::settings.javascriptEnabled
    \qmlproperty bool WebView::settings.javaEnabled
    \qmlproperty bool WebView::settings.pluginsEnabled
    \qmlproperty bool WebView::settings.privateBrowsingEnabled
    \qmlproperty bool WebView::settings.javascriptCanOpenWindows
    \qmlproperty bool WebView::settings.javascriptCanAccessClipboard
    \qmlproperty bool WebView::settings.developerExtrasEnabled
    \qmlproperty bool WebView::settings.linksIncludedInFocusChain
    \qmlproperty bool WebView::settings.zoomTextOnly
    \qmlproperty bool WebView::settings.printElementBackgrounds
    \qmlproperty bool WebView::settings.offlineStorageDatabaseEnabled
    \qmlproperty bool WebView::settings.offlineWebApplicationCacheEnabled
    \qmlproperty bool WebView::settings.localStorageDatabaseEnabled
    \qmlproperty bool WebView::settings.localContentCanAccessRemoteUrls

    These properties give access to the settings controlling the web view.

    See QWebSettings for details of these properties.

    \qml
    WebView {
        settings.pluginsEnabled: true
        settings.standardFontFamily: "Arial"
        // ...
    }
    \endqml
*/
KDeclarativeWebSettings* KDeclarativeWebView::settingsObject() const
{
    d->settings.s = page()->settings();
    return &d->settings;
}

void KDeclarativeWebView::setPage(QWebPage* page)
{
    if (d->view->page() == page)
        return;

    d->view->setPage(page);
    updateContentsSize();
    page->mainFrame()->setScrollBarPolicy(Qt::Horizontal, Qt::ScrollBarAlwaysOff);
    page->mainFrame()->setScrollBarPolicy(Qt::Vertical, Qt::ScrollBarAlwaysOff);
    connect(page->mainFrame(), SIGNAL(urlChanged(QUrl)), this, SLOT(pageUrlChanged()));
    connect(page->mainFrame(), SIGNAL(titleChanged(QString)), this, SIGNAL(titleChanged(QString)));
    connect(page->mainFrame(), SIGNAL(titleChanged(QString)), this, SIGNAL(iconChanged()));
    connect(page->mainFrame(), SIGNAL(iconChanged()), this, SIGNAL(iconChanged()));
    connect(page->mainFrame(), SIGNAL(initialLayoutCompleted()), this, SLOT(initialLayout()));
    connect(page->mainFrame(), SIGNAL(contentsSizeChanged(QSize)), this, SIGNAL(contentsSizeChanged(QSize)));

    connect(page, SIGNAL(loadStarted()), this, SLOT(doLoadStarted()));
    connect(page, SIGNAL(loadProgress(int)), this, SLOT(doLoadProgress(int)));
    connect(page, SIGNAL(loadFinished(bool)), this, SLOT(doLoadFinished(bool)));
    connect(page, SIGNAL(statusBarMessage(QString)), this, SLOT(setStatusText(QString)));

    connect(page->mainFrame(), SIGNAL(javaScriptWindowObjectCleared()), this, SLOT(windowObjectCleared()));

    page->settings()->setAttribute(QWebSettings::TiledBackingStoreEnabled, false);

}

/*!
    \qmlsignal WebView::onLoadStarted()

    This handler is called when the web engine begins loading
    a page. Later, WebView::onLoadFinished() or WebView::onLoadFailed()
    will be emitted.
*/

/*!
    \qmlsignal WebView::onLoadFinished()

    This handler is called when the web engine \e successfully
    finishes loading a page, including any component content
    (WebView::onLoadFailed() will be emitted otherwise).

    \sa progress
*/

/*!
    \qmlsignal WebView::onLoadFailed()

    This handler is called when the web engine fails loading
    a page or any component content
    (WebView::onLoadFinished() will be emitted on success).
*/

void KDeclarativeWebView::load(const QNetworkRequest& request, QNetworkAccessManager::Operation operation, const QByteArray& body)
{
    page()->mainFrame()->load(request, operation, body);
}

QString KDeclarativeWebView::html() const
{
    return page()->mainFrame()->toHtml();
}

/*!
    \qmlproperty string WebView::html
    This property holds HTML text set directly

    The html property can be set as a string.

    \qml
    WebView {
        html: "<p>This is <b>HTML</b>."
    }
    \endqml
*/
void KDeclarativeWebView::setHtml(const QString& html, const QUrl& baseUrl)
{
    updateContentsSize();
    if (isComponentComplete())
        page()->mainFrame()->setHtml(html, baseUrl);
    else {
        d->pending = d->PendingHtml;
        d->pendingUrl = baseUrl;
        d->pendingString = html;
    }
    emit htmlChanged();
}

void KDeclarativeWebView::setContent(const QByteArray& data, const QString& mimeType, const QUrl& baseUrl)
{
    updateContentsSize();

    if (isComponentComplete())
        page()->mainFrame()->setContent(data, mimeType, qmlContext(this)->resolvedUrl(baseUrl));
    else {
        d->pending = d->PendingContent;
        d->pendingUrl = baseUrl;
        d->pendingString = mimeType;
        d->pendingData = data;
    }
}

QWebHistory* KDeclarativeWebView::history() const
{
    return page()->history();
}

QWebSettings* KDeclarativeWebView::settings() const
{
    return page()->settings();
}

KDeclarativeWebView* KDeclarativeWebView::createWindow(QWebPage::WebWindowType type)
{
    switch (type) {
    case QWebPage::WebBrowserWindow: {
        if (!d->newWindowComponent && d->newWindowParent)
            qWarning("WebView::newWindowComponent not set - WebView::newWindowParent ignored");
        else if (d->newWindowComponent && !d->newWindowParent)
            qWarning("WebView::newWindowParent not set - WebView::newWindowComponent ignored");
        else if (d->newWindowComponent && d->newWindowParent) {
            KDeclarativeWebView* webview = 0;
            QDeclarativeContext* windowContext = new QDeclarativeContext(qmlContext(this));

            QObject* newObject = d->newWindowComponent->create(windowContext);
            if (newObject) {
                windowContext->setParent(newObject);
                QDeclarativeItem* item = qobject_cast<QDeclarativeItem *>(newObject);
                if (!item)
                    delete newObject;
                else {
                    webview = item->findChild<KDeclarativeWebView*>();
                    if (!webview)
                        delete item;
                    else {
                        newObject->setParent(d->newWindowParent);
                        static_cast<QGraphicsObject*>(item)->setParentItem(d->newWindowParent);
                    }
                }
            } else
                delete windowContext;

            return webview;
        }
    }
    break;
    case QWebPage::WebModalDialog: {
        // Not supported
    }
    }
    return 0;
}

/*!
    \qmlproperty component WebView::newWindowComponent

    This property holds the component to use for new windows.
    The component must have a WebView somewhere in its structure.

    When the web engine requests a new window, it will be an instance of
    this component.

    The parent of the new window is set by newWindowParent. It must be set.
*/
QDeclarativeComponent* KDeclarativeWebView::newWindowComponent() const
{
    return d->newWindowComponent;
}

void KDeclarativeWebView::setNewWindowComponent(QDeclarativeComponent* newWindow)
{
    if (newWindow == d->newWindowComponent)
        return;
    d->newWindowComponent = newWindow;
    emit newWindowComponentChanged();
}


/*!
    \qmlproperty item WebView::newWindowParent

    The parent item for new windows.

    \sa newWindowComponent
*/
QDeclarativeItem* KDeclarativeWebView::newWindowParent() const
{
    return d->newWindowParent;
}

void KDeclarativeWebView::setNewWindowParent(QDeclarativeItem* parent)
{
    if (parent == d->newWindowParent)
        return;
    if (d->newWindowParent && parent) {
        QList<QGraphicsItem *> children = d->newWindowParent->childItems();
        for (int i = 0; i < children.count(); ++i)
            children.at(i)->setParentItem(parent);
    }
    d->newWindowParent = parent;
    emit newWindowParentChanged();
}

QSize KDeclarativeWebView::contentsSize() const
{
    return page()->mainFrame()->contentsSize();
}

qreal KDeclarativeWebView::contentsScale() const
{
    if (renderingEnabled()) {
        return d->view->page()->mainFrame()->zoomFactor();
    } else {
        return d->view->scale();
    }
}

void KDeclarativeWebView::setContentsScale(qreal scale)
{
    if (scale == contentsScale())
        return;

    if (renderingEnabled()) {
        d->view->page()->mainFrame()->setZoomFactor(scale);
    } else {
        d->view->setScale(scale);
    }

    updateDeclarativeWebViewSize();
    emit contentsScaleChanged();
}

/*!
    Returns the area of the largest element at position (\a x,\a y) that is no larger
    than \a maxWidth by \a maxHeight pixels.

    May return an area larger in the case when no smaller element is at the position.
*/
QRect KDeclarativeWebView::elementAreaAt(int x, int y, int maxWidth, int maxHeight) const
{
    QWebHitTestResult hit = page()->mainFrame()->hitTestContent(QPoint(x, y));
    QRect hitRect = hit.boundingRect();
    QWebElement element = hit.enclosingBlockElement();
    if (maxWidth <= 0)
        maxWidth = INT_MAX;
    if (maxHeight <= 0)
        maxHeight = INT_MAX;
    while (!element.parent().isNull() && element.geometry().width() <= maxWidth && element.geometry().height() <= maxHeight) {
        hitRect = element.geometry();
        element = element.parent();
    }
    return hitRect;
}

/*!
    \internal
    \class QDeclarativeWebPage
    \brief The QDeclarativeWebPage class is a QWebPage that can create QML plugins.

    \sa KDeclarativeWebView
*/
QDeclarativeWebPage::QDeclarativeWebPage(KDeclarativeWebView* parent) :
    KWebPage(parent, KWalletIntegration)
{
    connect(this, SIGNAL(unsupportedContent(QNetworkReply*)), this, SLOT(handleUnsupportedContent(QNetworkReply*)));
//     //TODO: move this in the webbrowser implementation
    m_nepomukHelper = new NepomukHelper(this);
    // activate ssl warnings
    setSessionMetaData(QL1S("ssl_activate_warnings"), QL1S("TRUE"));
}

QDeclarativeWebPage::~QDeclarativeWebPage()
{
}

// Returns true if the scheme and domain of the two urls match...
static bool domainSchemeMatch(const QUrl& u1, const QUrl& u2)
{
    if (u1.scheme() != u2.scheme())
        return false;

    QStringList u1List = u1.host().split(QL1C('.'), QString::SkipEmptyParts);
    QStringList u2List = u2.host().split(QL1C('.'), QString::SkipEmptyParts);

    if (qMin(u1List.count(), u2List.count()) < 2)
        return false;  // better safe than sorry...

    while (u1List.count() > 2)
        u1List.removeFirst();

    while (u2List.count() > 2)
        u2List.removeFirst();

    return (u1List == u2List);
}

bool QDeclarativeWebPage::acceptNavigationRequest(QWebFrame *frame, const QNetworkRequest &request, NavigationType type)
{
    const bool isMainFrameRequest = (frame == mainFrame());

    if (frame)
    {
        /*if (_protHandler.preHandling(request, frame))
        {
            return false;
        }*/

        switch (type)
        {
        case QWebPage::NavigationTypeLinkClicked:
            if (m_sslInfo.isValid())
            {
                setRequestMetaData("ssl_was_in_use", "TRUE");
            }
            break;

        case QWebPage::NavigationTypeFormSubmitted:
            break;

        case QWebPage::NavigationTypeFormResubmitted:
            if (KMessageBox::warningContinueCancel(view(),
                                                   i18n("Are you sure you want to send your data again?"),
                                                   i18n("Resend form data")
                                                  )
                    == KMessageBox::Cancel)
            {
                return false;
            }
            break;

        case QWebPage::NavigationTypeReload:
            setRequestMetaData(QL1S("cache"), QL1S("reload"));
            break;

        case QWebPage::NavigationTypeBackOrForward:
        case QWebPage::NavigationTypeOther:
            break;

        default:
            //Q_ASSERT(0)
            break;
        }
    }

    // Get the SSL information sent, if any...
    KIO::AccessManager *manager = qobject_cast<KIO::AccessManager*>(networkAccessManager());
    KIO::MetaData metaData = manager->requestMetaData();
    if (metaData.contains(QL1S("ssl_in_use")))
    {
        WebSslInfo info;
        info.restoreFrom(metaData.toVariant(), request.url());
        info.setUrl(request.url());
        m_sslInfo = info;
    }

    if (isMainFrameRequest)
    {
        setRequestMetaData(QL1S("main_frame_request"), QL1S("TRUE"));
        if (m_sslInfo.isValid() && !domainSchemeMatch(request.url(), m_sslInfo.url()))
        {
            m_sslInfo = WebSslInfo();
        }
    }
    else
    {
        setRequestMetaData(QL1S("main_frame_request"), QL1S("FALSE"));
    }

    return KWebPage::acceptNavigationRequest(frame, request, type);
}

void QDeclarativeWebPage::manageNetworkErrors(QNetworkReply *reply)
{
    Q_ASSERT(reply);

    QWebFrame* frame = qobject_cast<QWebFrame *>(reply->request().originatingObject());
    if (!frame)
        return;

    const bool isMainFrameRequest = (frame == mainFrame());

    // Only deal with non-redirect responses...
    const QVariant redirectVar = reply->attribute(QNetworkRequest::RedirectionTargetAttribute);
    if (redirectVar.isValid())
    {
        m_sslInfo.restoreFrom(reply->attribute(static_cast<QNetworkRequest::Attribute>(KIO::AccessManager::MetaData)), reply->url());
        return;
    }

    // We are just managing loading URLs errors
   // if (reply->request().url() != _loadingUrl)
    //    return;

    // NOTE: These are not all networkreply errors,
    // but just that supported directly by KIO
    switch (reply->error())
    {

    case QNetworkReply::NoError:                             // no error. Simple :)
        if (isMainFrameRequest)
        {
            // Obtain and set the SSL information if any...
            m_sslInfo.restoreFrom(reply->attribute(static_cast<QNetworkRequest::Attribute>(KIO::AccessManager::MetaData)), reply->url());
            m_sslInfo.setUrl(reply->url());
        }
        break;

    case QNetworkReply::OperationCanceledError:              // operation canceled via abort() or close() calls
        // ignore this..
        return;

        // WARNING: This is also typical adblocked element error: IGNORE THIS!
    case QNetworkReply::ContentAccessDenied:                 // access to remote content denied
        break;

    case QNetworkReply::UnknownNetworkError:                 // unknown network-related error detected
        // last chance for the strange things (eg: FTP, custom schemes, etc...)
       // if (_protHandler.postHandling(reply->request(), mainFrame()))
       //     return;

    case QNetworkReply::ConnectionRefusedError:              // remote server refused connection
    case QNetworkReply::HostNotFoundError:                   // invalid hostname
    case QNetworkReply::TimeoutError:                        // connection time out
    case QNetworkReply::ProxyNotFoundError:                  // invalid proxy hostname
    case QNetworkReply::ContentOperationNotPermittedError:   // operation requested on remote content not permitted
    case QNetworkReply::ContentNotFoundError:                // remote content not found on server (similar to HTTP error 404)
    case QNetworkReply::ProtocolUnknownError:                // Unknown protocol
    case QNetworkReply::ProtocolInvalidOperationError:       // requested operation is invalid for this protocol
    default:
        break;

    }
}

QString QDeclarativeWebPage::chooseFile(QWebFrame* originatingFrame, const QString& oldFile)
{
    Q_UNUSED(originatingFrame)
    Q_UNUSED(oldFile)
    return KFileDialog::getOpenFileName();
}

/*!
    \qmlsignal WebView::onAlert(string message)

    The handler is called when the web engine sends a JavaScript alert. The \a message is the text
    to be displayed in the alert to the user.
*/


void QDeclarativeWebPage::javaScriptAlert(QWebFrame* originatingFrame, const QString& msg)
{
    // FIXME: implement alert
    Q_UNUSED(originatingFrame)
    emit viewItem()->alert(msg);
}

bool QDeclarativeWebPage::javaScriptConfirm(QWebFrame* originatingFrame, const QString& msg)
{
    // FIXME: Not supported (it's modal)
    Q_UNUSED(originatingFrame)
    Q_UNUSED(msg)
    return false;
}

bool QDeclarativeWebPage::javaScriptPrompt(QWebFrame* originatingFrame, const QString& msg, const QString& defaultValue, QString* result)
{
    // FIXME: Not supported (it's modal)
    Q_UNUSED(originatingFrame)
    Q_UNUSED(msg)
    Q_UNUSED(defaultValue)
    Q_UNUSED(result)
    return false;
}

QString QDeclarativeWebPage::userAgentForUrl(const QUrl &url) const
{
    QString agent = KWebPage::userAgentForUrl(url);

    //TODO: pretend to be android/iphone other mobile platforms?
    // with just Mobile Safari very few sites are serving a mobile version
    //with android user agent gmail doesn't seem to work correctly
    if (viewItem()->preferMobile()) {
        //this is extremely lame, but apparently websites are so lame that are explicitly checking for "android" or some toher strings
        return agent.replace(" Safari/", " Mobile Safari/").replace("X11", "X11, like Android");
    } else {
        return agent;
    }
}

KDeclarativeWebView* QDeclarativeWebPage::viewItem() const
{
    return static_cast<KDeclarativeWebView*>(parent());
}

QWebPage* QDeclarativeWebPage::createWindow(WebWindowType type)
{
    KDeclarativeWebView* newView = viewItem()->createWindow(type);
    if (newView)
        return newView->page();
    return 0;
}

void QDeclarativeWebPage::handleUnsupportedContent(QNetworkReply *reply)
{
    if (!reply) {
        return;
    }

    QUrl replyUrl = reply->url();

    if (replyUrl.scheme() == QLatin1String("abp"))
        return;

    if (reply->error() == QNetworkReply::NoError && reply->header(QNetworkRequest::ContentTypeHeader).isValid()) {
        downloadUrl(replyUrl);
    }
}

bool QDeclarativeWebPage::downloadResource (const KUrl& srcUrl, const QString& suggestedName,
                              QWidget* parent, const KIO::MetaData& metaData)
{

    const QString fileName ((suggestedName.isEmpty() ? srcUrl.fileName() : suggestedName));
    const KUrl &destUrl(QString("file://%1/%2").arg(QDir::homePath()).arg(fileName));

    if (!destUrl.isValid()) {
        return false;
    }

    KIO::CopyJob *job = KIO::copy(srcUrl, destUrl);

    if (!metaData.isEmpty()) {
        job->setMetaData(metaData);
    }

    job->setAutoRename(true);
    job->addMetaData(QLatin1String("MaxCacheSize"), QLatin1String("0")); // Don't store in http cache.
    job->addMetaData(QLatin1String("cache"), QLatin1String("cache")); // Use entry from cache if available.
    job->ui()->setWindow((parent ? parent->window() : 0));
    job->ui()->setAutoErrorHandlingEnabled(true);
    connect(job, SIGNAL(result(KJob*)), this, SLOT(downloadFinished(KJob*)));
    return true;
}

void QDeclarativeWebPage::downloadFinished(KJob *job)
{
    KIO::CopyJob *cj = qobject_cast<KIO::CopyJob*>(job);
    if (cj && job->error() == KJob::NoError) {

        KUrl localUrl = cj->destUrl();
        KUrl remoteUrl;
        foreach (const KUrl &_u, cj->srcUrls()) {
            remoteUrl = _u;
        }
        // add file to current activity, store remote url as metadata
        m_nepomukHelper->storeDownloadMetaData(remoteUrl, localUrl);

    } else {
        // TODO: handle download errors.
        kError() << "Error downloading file: " << job->errorString();
    }
}

void QDeclarativeWebPage::downloadRequest(const QNetworkRequest &request)
{
    downloadResource(request.url(), QString(), view(),
                     request.attribute(static_cast<QNetworkRequest::Attribute>(KIO::AccessManager::MetaData)).toMap());
}

void QDeclarativeWebPage::downloadUrl(const KUrl &url)
{
    downloadResource(url, QString(), view());
}


#include "errorhandling.cpp"


QT_END_NAMESPACE

