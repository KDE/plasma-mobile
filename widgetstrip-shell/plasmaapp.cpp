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
#include "../shell/widgetsexplorer/mobilewidgetsexplorer.h"

#include <unistd.h>

#include <QPixmapCache>
#include <QtDBus/QtDBus>
#include <QAction>

#include <KCrash>
#include <KColorUtils>
#include <KDebug>
#include <KCmdLineArgs>
#include <KWindowSystem>

#include <Plasma/Containment>
#include <Plasma/ContainmentActions>
#include <Plasma/Theme>
#include <Plasma/Corona>
#include <Plasma/Applet>
#include <Plasma/Wallpaper>
#include <Plasma/WindowEffects>

#include "singleview.h"
#include "stripcorona.h"


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
      m_view(0)
{
    KGlobal::locale()->insertCatalog("plasma-widgetsstripshell");
    KCrash::setFlags(KCrash::AutoRestart);

    KConfigGroup cg(KGlobal::config(), "General");
    Plasma::Theme::defaultTheme()->setFont(cg.readEntry("desktopFont", font()));

    corona();

    //newInstance();
    connect(this, SIGNAL(aboutToQuit()), this, SLOT(cleanup()));
    setQuitOnLastWindowClosed(true);
}

PlasmaApp::~PlasmaApp()
{
}

int  PlasmaApp::newInstance()
{
    if (m_view) {
        m_view->show();
        m_view->raise();
        return 0;
    }

    SingleView *view = new SingleView(m_corona);
    view->setWindowState(Qt::WindowMaximized);


    m_view = view;
    KWindowSystem::setOnDesktop(view->winId(), KWindowSystem::currentDesktop());
    view->show();
    view->raise();

    return 0;
}


void PlasmaApp::cleanup()
{
    if (m_corona) {
        m_corona->saveLayout();
    }

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
        m_corona = new StripCorona(this);
        connect(m_corona, SIGNAL(configSynced()), this, SLOT(syncConfig()));
        connect(m_corona, SIGNAL(containmentAdded(Plasma::Containment*)),
                this, SLOT(manageNewContainment(Plasma::Containment*)), Qt::QueuedConnection);

        m_corona->setItemIndexMethod(QGraphicsScene::NoIndex);
        m_corona->initializeLayout();
    }

    return m_corona;
}

bool PlasmaApp::hasComposite()
{
    return KWindowSystem::compositingActive();
}

void PlasmaApp::manageNewContainment(Plasma::Containment *containment)
{
    QAction *addAction = containment->action("add widgets");
    if (addAction) {
        connect(addAction, SIGNAL(triggered()), this, SLOT(showWidgetsExplorer()));
    }
}

void PlasmaApp::showWidgetsExplorer()
{
    if (!m_widgetsExplorer) {
        m_widgetsExplorer = new MobileWidgetsExplorer(0);
        m_widgetsExplorer.data()->setZValue(1000);
        m_corona->addItem(m_widgetsExplorer.data());
    }

    m_widgetsExplorer.data()->setContainment(m_view->containment());
    m_widgetsExplorer.data()->setGeometry(m_view->containment()->geometry());
    m_widgetsExplorer.data()->show();
}

#include "plasmaapp.moc"
