/*
 *   Copyright 2006-2008 Aaron Seigo <aseigo@kde.org>
 *   Copyright 2009 Marco Martin <notmart@gmail.com>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#include "plasmaapp.h"

#include "mobview.h"
#include "mobcorona.h"

#include <unistd.h>

#include <QApplication>
#include <QDesktopWidget>
#include <QPixmapCache>
#include <QtDBus/QtDBus>

#include <KAction>
#include <KCrash>
#include <KDebug>
#include <KCmdLineArgs>
#include <KStandardAction>
#include <KStandardDirs>
#include <KWindowSystem>
#include <KServiceTypeTrader>

#include <ksmserver_interface.h>

#include <Plasma/Containment>
#include <Plasma/Theme>
#include <Plasma/WindowEffects>
#include <Plasma/Applet>
#include <Plasma/Package>

#include <X11/Xlib.h>
#include <X11/extensions/Xrender.h>

extern void setupBindings();

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
      m_mainView(0)
{
    setupBindings();
    KGlobal::locale()->insertCatalog("libplasma");

    KCmdLineArgs *args = KCmdLineArgs::parsedArgs();
    bool isDesktop = args->isSet("desktop");
    if (isDesktop) {
        notifyStartup(false);
        KCrash::setFlags(KCrash::AutoRestart);
    }

    m_mainView = new MobView(0, MobView::mainViewId(), 0);
    connect(m_mainView, SIGNAL(containmentActivated()), this, SLOT(mainContainmentActivated()));

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

    //setIsDesktop(isDesktop);
    m_mainView->setFixedSize(width, height);
    m_mainView->move(0,0);

    KConfigGroup cg(KSharedConfig::openConfig("plasmarc"), "Theme-plasma-mobile");
    const QString themeName = cg.readEntry("name", "air-mobile");
    Plasma::Theme::defaultTheme()->setUseGlobalSettings(false);
    Plasma::Theme::defaultTheme()->setThemeName(themeName);

    cg = KConfigGroup(KGlobal::config(), "General");
    Plasma::Theme::defaultTheme()->setFont(cg.readEntry("desktopFont", font()));

    // this line initializes the corona and setups the main qml homescreen
    corona();
    connect(this, SIGNAL(aboutToQuit()), this, SLOT(cleanup()));
}

PlasmaApp::~PlasmaApp()
{
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

void PlasmaApp::syncConfig()
{
    KGlobal::config()->sync();
}

void PlasmaApp::setupHomeScreen()
{
    QUrl url(KStandardDirs::locate("appdata", "containments/homescreen/HomeScreen.qml"));

    m_engine = new QDeclarativeEngine(this);
    m_homescreen = new QDeclarativeComponent(m_engine, url, this);

    QObject *obj = m_homescreen->create();
    QDeclarativeItem *mainItem = qobject_cast<QDeclarativeItem*>(obj);

    // adds the homescreen to corona
    m_corona->addItem(mainItem);

    // get references for the main objects that we'll need to deal with
    m_mainSlot = mainItem->findChild<QDeclarativeItem*>("mainSlot");
    m_mainSlot->setZValue(9997);

    m_spareSlot = mainItem->findChild<QDeclarativeItem*>("spareSlot");
    m_mainSlot->setZValue(9998);

    m_panel = mainItem->findChild<QDeclarativeItem*>("activitypanel");
    m_panel->setZValue(9999);

    m_mainView->setSceneRect(mainItem->x(), mainItem->y(),
                             mainItem->width(), mainItem->height());

    QDeclarativeItem *panelItems = m_panel->findChild<QDeclarativeItem*>("panelitems");

    foreach(QObject *item, panelItems->children()) {
        connect(item, SIGNAL(clicked()), this, SLOT(changeActivity()));
    }
}

void PlasmaApp::changeActivity()
{
    QDeclarativeItem *item = qobject_cast<QDeclarativeItem*>(sender());
    Plasma::Containment *containment = containments.value(item->objectName().toInt());

    // found it!
    if (containment) {
        setupContainment(containment);
    }
}

Plasma::Corona* PlasmaApp::corona()
{
    if (!m_corona) {
        m_corona = new MobCorona(this);
        m_corona->setItemIndexMethod(QGraphicsScene::NoIndex);

        connect(m_corona, SIGNAL(containmentAdded(Plasma::Containment*)),
                this, SLOT(manageNewContainment(Plasma::Containment*)));
        connect(m_corona, SIGNAL(configSynced()), this, SLOT(syncConfig()));


        // setup our QML home screen;
        setupHomeScreen();
        m_corona->initializeLayout();

        m_mainView->setScene(m_corona);
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

    const QString startupID("workspace desktop");
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

void PlasmaApp::setupContainment(Plasma::Containment *containment)
{
    // we should deal with the layout logic here
    // discover if we setup the home containment, etc..
    if (containment->parentItem()) {
        containment->parentItem()->setParentItem(m_mainSlot);
    } else {
        containment->setParentItem(m_mainSlot);
    }

    // resizing the containment will always resize it's parent item
    containment->parentItem()->setPos(m_mainSlot->x(), m_mainSlot->y());
}

void PlasmaApp::manageNewContainment(Plasma::Containment *containment)
{
    // add the containment and it identifier to a hash to enable us
    // to retrieve it later.
    containments.insert(containment->id(), containment);


    if (containment->id() == 1) {
        setupContainment(containment);
        return;
    }

    // XXX: FIX ME with beautiful values :)
    containment->parentItem()->setPos(900, 900);

    kDebug() << "--------------------------------------------------";
    QDeclarativeItem *obj = dynamic_cast<QDeclarativeItem*>(containment->parentItem());
    kDebug() << "---> x: " << containment->x();
    kDebug() << "---> y: " << containment->y();
    kDebug() << "---> s: " << containment->size();
    kDebug() << "---> pw: " << obj->width();
    kDebug() << "---> ph: " << obj->height();
    kDebug() << "--------------------------------------------------";
}

#include "plasmaapp.moc"
