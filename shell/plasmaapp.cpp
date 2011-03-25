/***************************************************************************
 *   Copyright 2006-2008 Aaron Seigo <aseigo@kde.org>                      *
 *   Copyright 2009 Marco Martin <notmart@gmail.com>                       *
 *   Copyright 2010 Alexis Menard <menard@kde.org>                         *
 *   Copyright 2010 Artur Duque de Souza <asouza@kde.org>                  *
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

#include "plasmaapp.h"

#include "mobview.h"
#include "mobcorona.h"
#include "widgetsexplorer/mobilewidgetsexplorer.h"

#include <unistd.h>

#include <QApplication>
#include <QDesktopWidget>
#include <QGraphicsEffect>
#include <QPixmapCache>
#include <QtDBus/QtDBus>

#include <KAction>
#include <KCrash>
#include <KDebug>
#include <KCmdLineArgs>
#include <KStandardAction>
#include <KStandardDirs>
#include <KGlobalAccel>
#include <KWindowSystem>
#include <KServiceTypeTrader>

#include <ksmserver_interface.h>

#include <Plasma/Containment>
#include <Plasma/Context>
#include <Plasma/DeclarativeWidget>
#include <Plasma/Theme>
#include <Plasma/WindowEffects>
#include <Plasma/Applet>
#include <Plasma/Package>
#include <Plasma/Wallpaper>

#include <X11/Xlib.h>
#include <X11/extensions/Xrender.h>

class CachingEffect : public QGraphicsEffect
{
  public :
    CachingEffect(QObject *parent = 0) : QGraphicsEffect(parent)
    {}

    void draw(QPainter *p)
    {
        QPoint point;
        QPixmap pixmap = sourcePixmap(Qt::LogicalCoordinates, &point);
        //maybe we are in a view with save and restore disabled..
        p->setCompositionMode(QPainter::CompositionMode_Source);

        p->drawPixmap(point, pixmap);
        p->setCompositionMode(QPainter::CompositionMode_SourceOver);
    }

    QPixmap cachedPixmap() const
    {
        QPoint point;
        return sourcePixmap(Qt::LogicalCoordinates, &point);
    }
};

PlasmaApp* PlasmaApp::self()
{
    if (!kapp) {
        return new PlasmaApp();
    }

    return qobject_cast<PlasmaApp*>(kapp);
}

PlasmaApp::PlasmaApp()
    : KUniqueApplication(),
      m_corona(0),
      m_mainView(0),
      m_currentContainment(0),
      m_isDesktop(false)
{
    KGlobal::locale()->insertCatalog("libplasma");

    KCmdLineArgs *args = KCmdLineArgs::parsedArgs();

    //FIXME: why does not work?
    //qmlRegisterInterface<Plasma::Wallpaper>("Wallpaper");
    //qRegisterMetaType<Plasma::Wallpaper*>("Wallpaper");

    bool useGL = args->isSet("opengl");
    m_mainView = new MobView(0, MobView::mainViewId(), 0);
    m_mainView->setUseGL(useGL);

    bool isDesktop = args->isSet("desktop");
    if (isDesktop) {
        notifyStartup(false);
        KCrash::setFlags(KCrash::AutoRestart);
        //FIXME: uncomment on everyhting that is not Maemo
        //m_mainView->setWindowFlags(Qt::FramelessWindowHint);
    }


    int width = 800;
    int height = 480;
    if (isDesktop) {
        QRect rect = QApplication::desktop()->screenGeometry(m_mainView->screen());
        width = rect.width();
        height = rect.height();
    } else {
        QAction *action = KStandardAction::quit(qApp, SLOT(quit()), m_mainView);
        m_mainView->addAction(action);

        QString geom = args->getOption("screen");
        int x = geom.indexOf('x');

        if (x > 0)  {
            width = qMax(width, geom.left(x).toInt());
            height = qMax(height, geom.right(geom.length() - x - 1).toInt());
        }
    }

    bool isFullScreen = args->isSet("fullscreen");
    if (isFullScreen) {
        m_mainView->showFullScreen();
    }

    setIsDesktop(isDesktop);
    m_mainView->setFixedSize(width, height);
    m_mainView->move(0,0);

    KConfigGroup cg(KSharedConfig::openConfig("plasmarc"), "Theme-plasma-mobile");
    const QString themeName = cg.readEntry("name", "air-mobile");
    Plasma::Theme::defaultTheme()->setUseGlobalSettings(false);
    Plasma::Theme::defaultTheme()->setThemeName(themeName);

    cg = KConfigGroup(KGlobal::config(), "General");
    Plasma::Theme::defaultTheme()->setFont(cg.readEntry("desktopFont", font()));

    m_homeScreenPath = KGlobal::mainComponent().componentName() + "-homescreen";
    kDebug() << "***** HSP from config" << m_homeScreenPath;

    // this line initializes the corona and setups the main qml homescreen
    corona();
    connect(this, SIGNAL(aboutToQuit()), this, SLOT(cleanup()));

    KAction *lockAction = new KAction(this);
    lockAction->setText(i18n("Lock Plasma Mobile screen"));
    lockAction->setObjectName(QString("lock screen")); // NO I18

    KGlobalAccel::cleanComponent(KGlobal::mainComponent().componentName());
    lockAction->setGlobalShortcut(KShortcut(Qt::CTRL + Qt::Key_L));
    m_mainView->addAction(lockAction);
    connect(lockAction, SIGNAL(triggered()), this, SLOT(lockScreen()));
}

PlasmaApp::~PlasmaApp()
{
}

QList<Plasma::Containment *> PlasmaApp::containments() const
{
    return m_containments.values();
}

QList<Plasma::Containment *> PlasmaApp::panelContainments() const
{
    return m_panelContainments.values();
}

void PlasmaApp::cleanup()
{
    if (m_corona) {
        m_corona->saveLayout();
    }

    delete m_mainView;
    m_mainView = 0;

    delete m_corona;
    m_corona = 0;

    //TODO: This manual sync() should not be necessary?
    syncConfig();
}

void PlasmaApp::setIsDesktop(bool isDesktop)
{
    m_isDesktop = isDesktop;

    if (isDesktop) {
        KWindowSystem::setType(m_mainView->winId(), NET::Normal);
        m_mainView->setWindowFlags(m_mainView->windowFlags() | Qt::FramelessWindowHint);
        KWindowSystem::setOnAllDesktops(m_mainView->winId(), true);
        m_mainView->show();
    } else {
        m_mainView->setWindowFlags(m_mainView->windowFlags() & ~Qt::FramelessWindowHint);
        KWindowSystem::setOnAllDesktops(m_mainView->winId(), false);
        KWindowSystem::setType(m_mainView->winId(), NET::Normal);
    }
}

void PlasmaApp::syncConfig()
{
    KGlobal::config()->sync();
}

void PlasmaApp::setupHomeScreen()
{
    if (m_declarativeWidget) {
        kWarning() << "The home screen can be set up a single time";
    }

    m_declarativeWidget = new Plasma::DeclarativeWidget();
    m_corona->addItem(m_declarativeWidget);

    if (m_homeScreenPath.isEmpty()) {
        kWarning() << "***** m_homeScreenPath is empty, this should not happen. Trying to correct it.";
        m_homeScreenPath = QString("mobile-homescreen");
    }

    QString qmlPath = KStandardDirs::locate("data", QString("plasma-mobile/%1/HomeScreen.qml").arg(m_homeScreenPath));
    if (qmlPath.isEmpty()) {
        kWarning() << "***** QML File not found.";
        kDebug() << "CFG:" << m_homeScreenPath;
        kDebug() << "HSP:" << QString(m_homeScreenPath).append("/HomeScreen.qml");
        kDebug() << "KSD:" << KStandardDirs::locate("data", "plasma-mobile/mobile-homescreen/HomeScreen.qml");
    }
    kDebug() << "QML:" << qmlPath;
    m_declarativeWidget->setQmlPath(qmlPath);

    if (!m_declarativeWidget->engine()) {
        QCoreApplication::quit();
    }

    QDeclarativeItem *mainItem = qobject_cast<QDeclarativeItem*>(m_declarativeWidget->rootObject());

    m_homeScreen = mainItem;
    mainViewGeometryChanged();
    connect(m_mainView, SIGNAL(geometryChanged()), this, SLOT(mainViewGeometryChanged()));
    connect(m_mainView, SIGNAL(containmentActivated()), this, SLOT(mainContainmentActivated()));

    connect(m_homeScreen, SIGNAL(transformingChanged(bool)), this, SLOT(containmentsTransformingChanged(bool)));


    connect(m_homeScreen, SIGNAL(nextActivityRequested()),
            m_corona, SLOT(activateNextActivity()));

    connect(m_homeScreen, SIGNAL(previousActivityRequested()),
            m_corona, SLOT(activatePreviousActivity()));

    QDeclarativeItem *panel = mainItem->findChild<QDeclarativeItem*>("activitypanel");

    m_mainView->setSceneRect(mainItem->x(), mainItem->y(),
                             mainItem->width(), mainItem->height());

    QDeclarativeItem *panelItems = panel->findChild<QDeclarativeItem*>("panelitems");

    if (panelItems) {
        foreach(QObject *item, panelItems->children()) {
            connect(item, SIGNAL(clicked()), this, SLOT(changeActivity()));
        }
    }
}

void PlasmaApp::containmentsTransformingChanged(bool transforming)
{
    if (m_currentContainment && m_currentContainment->graphicsEffect()) {
        m_currentContainment->graphicsEffect()->setEnabled(transforming);
    }
    if (m_oldContainment && m_oldContainment.data()->graphicsEffect()) {
        m_oldContainment.data()->graphicsEffect()->setEnabled(transforming);
        //take a snapshot of the old one
        //TODO: make this async?
        if (transforming) {
            QGraphicsEffect *effect = m_oldContainment.data()->graphicsEffect();
            CachingEffect *cache = dynamic_cast<CachingEffect *>(effect);

            QImage activityImage(m_oldContainment.data()->size().toSize(), QImage::Format_ARGB32);
            QPainter p(&activityImage);
            m_oldContainment.data()->wallpaper()->paint(&p, m_oldContainment.data()->wallpaper()->boundingRect());
            p.setCompositionMode(QPainter::CompositionMode_SourceOver);
            p.drawPixmap(QPoint(0,0), cache->cachedPixmap());
            p.end();

            QString path = KStandardDirs::locateLocal("data", QString("plasma/activities-screenshots/%1.png").arg(m_oldContainment.data()->context()->currentActivityId()));

            activityImage.save(path, "PNG");
        }
    }
    foreach (Plasma::Containment *cont, m_alternateContainments) {
        if (cont->graphicsEffect()) {
            cont->graphicsEffect()->setEnabled(transforming);
        }
    }
}


void PlasmaApp::changeContainment(Plasma::Containment *containment)
{
    QDeclarativeProperty containmentProperty(m_homeScreen, "activeContainment");
    containmentProperty.write(QVariant::fromValue(static_cast<QGraphicsWidget*>(containment)));

    m_oldContainment = m_currentContainment;

    //FIXME: it should be possible to access containment.wallpaper
    //expose the current wallpaper into the corona QML
    if (containment->wallpaper()) {
        QDeclarativeProperty containmentProperty(m_homeScreen, "activeWallpaper");
        containmentProperty.write(QVariant::fromValue(static_cast<QObject*>(containment->wallpaper())));
    }

    m_currentContainment = containment;
}

void PlasmaApp::lockScreen()
{
    m_homeScreen->setProperty("locked", true);
}

Plasma::Corona* PlasmaApp::corona()
{
    if (!m_corona) {
        m_corona = new MobCorona(this);
        m_corona->setItemIndexMethod(QGraphicsScene::NoIndex);
        m_corona->setScreenGeometry(QRect(QPoint(0,0), m_mainView->transformedSize()));

        connect(m_corona, SIGNAL(containmentAdded(Plasma::Containment*)),
                this, SLOT(manageNewContainment(Plasma::Containment*)));
        connect(m_corona, SIGNAL(configSynced()), this, SLOT(syncConfig()));
        connect(m_corona, SIGNAL(screenOwnerChanged(int, int, Plasma::Containment *)), this, SLOT(containmentScreenOwnerChanged(int,int,Plasma::Containment*)));


        // setup our QML home screen;
        setupHomeScreen();
        m_corona->initializeLayout();

        m_mainView->setScene(m_corona);
        m_corona->checkActivities();
        m_mainView->show();
    }
    return m_corona;
}

bool PlasmaApp::hasComposite()
{
    return KWindowSystem::compositingActive();
}

void PlasmaApp::notifyStartup(bool completed)
{
    org::kde::KSMServerInterface ksmserver("org.kde.ksmserver",
                                           "/KSMServer", QDBusConnection::sessionBus());

    const QString startupID("mobile desktop");
    if (completed) {
        ksmserver.resumeStartup(startupID);
    } else {
        ksmserver.suspendStartup(startupID);
    }
}

void PlasmaApp::mainContainmentActivated()
{
    m_mainView->setWindowTitle(m_mainView->containment()->activity());
    const WId id = m_mainView->effectiveWinId();

    QWidget * activeWindow = QApplication::activeWindow();
    KWindowSystem::raiseWindow(id);

    if (activeWindow) {
        KWindowSystem::raiseWindow(activeWindow->effectiveWinId());
        m_mainView->activateWindow();
        activeWindow->setFocus();
    } else {
        m_mainView->activateWindow();
    }
}


void PlasmaApp::manageNewContainment(Plasma::Containment *containment)
{
    if (m_containments.contains(containment->id()) || m_panelContainments.contains(containment->location())) {
        return;
    }
    QAction *addAction = containment->action("add widgets");
    if (addAction) {
        connect(addAction, SIGNAL(triggered()), this, SLOT(showWidgetsExplorer()));
    }

    //Is it a panel?
    //if it's on an edge find a qml element propely named
    //otherwise delete it
    QString containmentPanelName;

    switch (containment->location()) {
    case Plasma::LeftEdge:
        containmentPanelName = "leftEdgePanel";
        break;
    case Plasma::TopEdge:
        containmentPanelName = "topEdgePanel";
        break;
    case Plasma::RightEdge:
        containmentPanelName = "rightEdgePanel";
        break;
    case Plasma::BottomEdge:
        containmentPanelName = "bottomEdgePanel";
        break;
    default:
        break;
    }

    //is it a panel?
    if (!containmentPanelName.isEmpty()) {
        QDeclarativeItem *containmentPanel = m_homeScreen->findChild<QDeclarativeItem*>(containmentPanelName);

        if (containmentPanel) {
            containment->setParentItem(containmentPanel);
            containment->setParent(containmentPanel);

            QDeclarativeProperty containmentProperty(containmentPanel, "containment");
            containmentProperty.write(QVariant::fromValue(static_cast<QGraphicsWidget*>(containment)));

            m_panelContainments.insert(containment->location(), containment);

            //done, don't need further management
            return;
        } else {
            //no panel? discard the containment
            containment->deleteLater();
            return;
        }
    }


    // add the containment and it identifier to a hash to enable us
    // to retrieve it later.
    m_containments.insert(containment->id(), containment);

    connect(containment, SIGNAL(destroyed(QObject *)), this, SLOT(containmentDestroyed(QObject *)));


    CachingEffect *effect = new CachingEffect(containment);
    containment->setGraphicsEffect(effect);
    containment->graphicsEffect()->setEnabled(false);

    containment->resize(m_mainView->transformedSize());

    // we need our homescreen to show something!
    // for the alternate screen (such as a launcher) we need a containment setted as excludeFromActivities
    //FIXME: use only the declarativeSlot key?
    if (containment->config().readEntry("excludeFromActivities", false)) {
        QString declarativeSlot = containment->config().readEntry("declarativeSlot", "alternateSlot");

        QDeclarativeItem *alternateSlot = m_homeScreen->findChild<QDeclarativeItem*>(declarativeSlot);

        if (alternateSlot) {
            m_alternateContainments << containment;
            alternateSlot->setProperty("width", m_mainView->transformedSize().width());
            alternateSlot->setProperty("height", m_mainView->transformedSize().height());
            containment->setParentItem(alternateSlot);
            containment->setParent(alternateSlot);
            containment->setPos(0, 0);
            containment->setVisible(true);
            return;
        }
    } else if (containment->screen() > -1) {
        changeContainment(containment);
    } else {
        containment->setPos(m_mainView->width(), m_mainView->height());
       // containment->setVisible(false);
    }
}

void PlasmaApp::mainViewGeometryChanged()
{
    if (m_declarativeWidget) {

        //sometimes a geometry change arives very early in the ctor
        corona();
        m_declarativeWidget->resize(m_mainView->transformedSize());
        //m_declarativeWidget->setPos(m_mainView->mapToScene(QPoint(0,0)));
        m_declarativeWidget->setGeometry(m_mainView->mapToScene(QRect(QPoint(0,0), m_mainView->size())).boundingRect());

        QRect availableScreenRect(QPoint(0,0), m_mainView->size());
        QDeclarativeItem *availableScreenRectItem = m_homeScreen->findChild<QDeclarativeItem*>("availableScreenRect");
        //is there an item that defines the screen geometry?
        if (availableScreenRectItem) {
            availableScreenRect = QRect((int)availableScreenRectItem->property("x").toReal(),
                              (int)availableScreenRectItem->property("y").toReal(),
                              (int)availableScreenRectItem->property("width").toReal(),
                              (int)availableScreenRectItem->property("height").toReal());
            //are we rotated?
            availableScreenRect = m_mainView->transformedRect(availableScreenRect);

            const int left = availableScreenRectItem->property("leftReserved").toInt();
            const int top = availableScreenRectItem->property("topReserved").toInt();
            const int right = availableScreenRectItem->property("rightReserved").toInt();
            const int bottom = availableScreenRectItem->property("bottomReserved").toInt();
            reserveStruts(left, top, right, bottom);
        }

        m_corona->setScreenGeometry(QRect(QPoint(0, 0), m_mainView->transformedSize()));
        m_corona->setAvailableScreenRegion(availableScreenRect);

        if (m_currentContainment) {
            m_currentContainment->resize(m_mainView->transformedSize());
        }
        foreach (Plasma::Containment *cont, m_alternateContainments) {
            cont->resize(m_mainView->transformedSize());
            cont->setPos(0, 0);
        }
        if (m_widgetsExplorer) {
            m_widgetsExplorer.data()->setGeometry(m_declarativeWidget->geometry());
        }
    }
}

void PlasmaApp::reserveStruts(const int left, const int top, const int right, const int bottom)
{
    if (!m_mainView) {
        return;
    }

    if (!m_isDesktop) {
        KWindowSystem::setExtendedStrut(m_mainView->winId(),
                                    0, 0, 0,
                                    0, 0, 0,
                                    0, 0, 0,
                                    0, 0, 0);
        return;
    }

    NETExtendedStrut strut;

    if (left) {
        strut.left_width = left;
        strut.left_start = m_mainView->y();
        strut.left_end = m_mainView->y() + m_mainView->height() - 1;
    }
    if (right) {
        strut.right_width = right;
        strut.right_start = m_mainView->y();
        strut.right_end = m_mainView->y() + m_mainView->height() - 1;
    }
    if (top) {
        strut.top_width = top;
        strut.top_start = m_mainView->x();
        strut.top_end = m_mainView->x() + m_mainView->width() - 1;
    }
    if (bottom) {
        strut.bottom_width = bottom;
        strut.bottom_start = m_mainView->x();
        strut.bottom_end = m_mainView->x() + m_mainView->width() - 1;
    }


    const QPoint oldPos = m_mainView->pos();

    KWindowSystem::setExtendedStrut(m_mainView->winId(),
                                    strut.left_width, strut.left_start, strut.left_end,
                                    strut.right_width, strut.right_start, strut.right_end,
                                    strut.top_width, strut.top_start, strut.top_end,
                                    strut.bottom_width, strut.bottom_start, strut.bottom_end);

    //ensure the main view is at the proper position too
    m_mainView->move(oldPos);
}

void PlasmaApp::showWidgetsExplorer()
{
    if (!m_widgetsExplorer) {
        m_widgetsExplorer = new MobileWidgetsExplorer(0);
        m_widgetsExplorer.data()->setZValue(1000);
        m_corona->addItem(m_widgetsExplorer.data());
    }

    m_widgetsExplorer.data()->setContainment(m_currentContainment);
    if (m_declarativeWidget) {
        m_widgetsExplorer.data()->setGeometry(m_declarativeWidget->geometry());
    }
    m_widgetsExplorer.data()->show();
}

void PlasmaApp::containmentDestroyed(QObject *object)
{
    Plasma::Containment *cont = qobject_cast<Plasma::Containment *>(object);

    if (cont) {
        m_containments.remove(cont->id());
    }
}

void PlasmaApp::containmentScreenOwnerChanged(int wasScreen, int isScreen, Plasma::Containment *cont)
{
    bool excludeFromActivities = cont->config().readEntry("excludeFromActivities", false);

    if (!excludeFromActivities && isScreen >= 0 && (cont->location() == Plasma::Desktop || cont->location() == Plasma::Floating)) {
        changeContainment(cont);
    }
}

#include "plasmaapp.moc"
