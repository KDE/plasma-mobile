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
#include <QPixmapCache>
#include <QtDBus/QtDBus>
#include <QtDeclarative/QmlComponent>
#include <QtDeclarative/QmlEngine>

#include <KAction>
#include <KCrash>
#include <KDebug>
#include <KCmdLineArgs>
#include <KStandardAction>
#include <KStandardDirs>
#include <KWindowSystem>
#include <KServiceTypeTrader>

#include <ksmserver_interface.h>

#include <kephal/screens.h>

#include <Plasma/Containment>
#include <Plasma/Theme>
#include <Plasma/WindowEffects>
#include <Plasma/Applet>

#include <X11/Xlib.h>
#include <X11/extensions/Xrender.h>

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
    KGlobal::locale()->insertCatalog("libplasma");
    KGlobal::locale()->insertCatalog("plasmagenericshell");


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
        QRect rect = Kephal::ScreenUtils::screenGeometry(m_mainView->screen());
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
    
    KConfigGroup cg(KSharedConfig::openConfig("plasmarc"), "Theme-plasma-mobile-qml");
    const QString themeName = cg.readEntry("name", "air-mobile");
    Plasma::Theme::defaultTheme()->setUseGlobalSettings(false);
    Plasma::Theme::defaultTheme()->setThemeName(themeName);
    
    cg = KConfigGroup(KGlobal::config(), "General");
    Plasma::Theme::defaultTheme()->setFont(cg.readEntry("desktopFont", font()));

    // this line initializes the corona.
    corona();
    
    QmlEngine *engine = new QmlEngine(m_mainView);
    QmlComponent *component = new QmlComponent(engine, ":interface.qml");
    QGraphicsObject *item = qobject_cast<QGraphicsObject *>(component->create());
    if (item)
        m_corona->addItem(item);
    else
        qDebug()<< "Error occured" << component->errors();

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

Plasma::Corona* PlasmaApp::corona()
{
    if (!m_corona) {
        m_corona = new MobCorona(this);
        connect(m_corona, SIGNAL(containmentAdded(Plasma::Containment*)),
                this, SLOT(createView(Plasma::Containment*)));
        connect(m_corona, SIGNAL(configSynced()), this, SLOT(syncConfig()));

        m_corona->setItemIndexMethod(QGraphicsScene::NoIndex);
        m_corona->initializeLayout();
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
    org::kde::KSMServerInterface ksmserver("org.kde.ksmserver", "/KSMServer", QDBusConnection::sessionBus());

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

    /*if (!m_isDesktop) {
        return;
    }*/

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

void PlasmaApp::createView(Plasma::Containment *containment)
{
    m_mainView->setContainment(containment);
    connect(containment, SIGNAL(showAddWidgetsInterface(QPointF)), this, SLOT(showWidgetExplorer()));
    containment->setScreen(0);
}

void PlasmaApp::showWidgetExplorer()
{
    kDebug()<<"Implement Me : Widget Explorer";
    foreach (const KPluginInfo &info, Plasma::Applet::listAppletInfo(QString())) {
        //kDebug() << info.pluginName() << "NoDisplay" << info.property("NoDisplay").toBool();
        if (info.property("NoDisplay").toBool() || info.category() == i18n("Containments")) {
            // we don't want to show the hidden category
            continue;
        }
        kDebug() << info.pluginName() << " is the name of the plugin\n";

        //qDebug() << info.name() << info.property("X-Plasma-Thumbnail");
        //qDebug() << info.entryPath();

    }
}

#include "plasmaapp.moc"
