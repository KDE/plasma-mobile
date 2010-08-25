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
#include "plasmakeyboardshelladaptor.h"

#include <unistd.h>

#include <QApplication>
#include <QPixmapCache>
#include <QTimer>
#include <QVBoxLayout>
#include <QtDBus/QtDBus>
#include <QDesktopWidget>

#include <KAction>
#include <KCrash>
#include <KColorUtils>
#include <KDebug>
#include <KStandardAction>
#include <KWindowSystem>

#include <Plasma/Containment>
#include <Plasma/Theme>
#include <Plasma/Corona>
#include <Plasma/PopupApplet>
#include <Plasma/Wallpaper>
#include <Plasma/WindowEffects>

#include "singleview.h"


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
      m_maxId(0)
{
    KGlobal::locale()->insertCatalog("plasma-keyboardcontainer");
    KCrash::setFlags(KCrash::AutoRestart);

    KConfigGroup cg(KGlobal::config(), "General");
    Plasma::Theme::defaultTheme()->setFont(cg.readEntry("desktopFont", font()));

    corona();
    m_containment = m_corona->addContainment("null");

    new PlasmaKeyboardAdaptor(this);
    QDBusConnection::sessionBus().registerObject("/App", this);

    KConfigGroup containmentConfig = m_containment->config();
    KConfigGroup applets(&containmentConfig, "Applets");

    foreach (const QString &group, applets.groupList()) {
        KConfigGroup appletGroup(&applets, group);

        int id = appletGroup.name().toInt();
        QString pluginName = appletGroup.readEntry("plugin", QString());
        if (id != 0 && !pluginName.isEmpty()) {
            m_storedApplets.insert(pluginName, id);
            m_maxId = qMax(id, m_maxId);
        }
    }

    //newInstance();
    connect(this, SIGNAL(aboutToQuit()), this, SLOT(cleanup()));
}

PlasmaApp::~PlasmaApp()
{
}

int  PlasmaApp::newInstance()
{

    QString pluginName = "plasmaboard";

    int appletId;
    if (m_storedApplets.contains(pluginName)) {
        appletId = m_storedApplets.values(pluginName).first();
        m_storedApplets.remove(pluginName, appletId);
    } else {
        appletId = ++m_maxId;
    }

    SingleView *view = new SingleView(m_corona, m_containment, pluginName, appletId, QVariantList());
    view->installEventFilter(this);

    view->setWindowFlags(Qt::FramelessWindowHint);
    KWindowSystem::setType(view->winId(), NET::Dock);
    view->setAutoFillBackground(true);
    view->setBackgroundBrush(KColorUtils::mix(Plasma::Theme::defaultTheme()->color(Plasma::Theme::BackgroundColor), Plasma::Theme::defaultTheme()->color(Plasma::Theme::TextColor), 0.15));
    view->setAttribute(Qt::WA_NoSystemBackground);
    view->viewport()->setAttribute(Qt::WA_NoSystemBackground);
    Plasma::WindowEffects::overrideShadow(view->winId(), true);
    connect(Plasma::Theme::defaultTheme(), SIGNAL(themeChanged()), SLOT(themeChanged()));
    view->applet()->setBackgroundHints(Plasma::Applet::NoBackground);

    view->show();

    m_views.append(view);

    return 0;
}


void PlasmaApp::cleanup()
{
    if (m_corona) {
        m_corona->saveLayout();
    }

    qDeleteAll(m_views);

    delete m_corona;
    m_corona = 0;

    //TODO: This manual sync() should not be necessary?
    syncConfig();
}

void PlasmaApp::syncConfig()
{
    KGlobal::config()->sync();
}

void PlasmaApp::themeChanged()
{
    foreach(SingleView *view, m_views) {
        if (view->autoFillBackground()) {
            view->setBackgroundBrush(KColorUtils::mix(Plasma::Theme::defaultTheme()->color(Plasma::Theme::BackgroundColor), Plasma::Theme::defaultTheme()->color(Plasma::Theme::TextColor), 0.15));
        }
    }
}

Plasma::Corona* PlasmaApp::corona()
{
    if (!m_corona) {
        m_corona = new Plasma::Corona(this);
        connect(m_corona, SIGNAL(configSynced()), this, SLOT(syncConfig()));


        m_corona->setItemIndexMethod(QGraphicsScene::NoIndex);
        //m_corona->initializeLayout();
    }

    return m_corona;
}

bool PlasmaApp::hasComposite()
{
    return KWindowSystem::compositingActive();
}


bool PlasmaApp::eventFilter(QObject *watched, QEvent *event)
{
    /*if (event->type() == QEvent::Hide) {
        SingleView *view = qobject_cast<SingleView *>(watched);

        if (view) {
            m_storedApplets.insert(view->applet()->name(), view->applet()->id());
            view->deleteLater();
            m_views.removeAll(view);
        }
    }*/
    return false;
}

void PlasmaApp::setDirection(const QString &direction)
{
    Plasma::Direction dir;
    if (direction == "up") {
        dir = Plasma::Up;
    } else if (direction == "down") {
        dir = Plasma::Down;
    } else if (direction == "left") {
        dir = Plasma::Left;
    } else if (direction == "right") {
        dir = Plasma::Right;
    } else {
        dir = Plasma::Down;
    }

    foreach(SingleView *view, m_views) {
        view->setDirection(dir);
    }
}

void PlasmaApp::show()
{
    foreach(SingleView *view, m_views) {
        view->show();
    }
}

void PlasmaApp::hide()
{
    foreach(SingleView *view, m_views) {
        view->hide();
    }
}

#include "plasmaapp.moc"
