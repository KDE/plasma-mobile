/*
 *   Copyright 2008 Aaron Seigo <aseigo@kde.org>
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

#include "mobcorona.h"

#include <QApplication>
#include <QDesktopWidget>
#include <QDir>
#include <QGraphicsLayout>

#include <KCmdLineArgs>
#include <KDebug>
#include <KDialog>
#include <KGlobalSettings>
#include <KStandardDirs>

#include <kephal/screens.h>

#include <Plasma/Containment>
#include <Plasma/DataEngineManager>

#include "plasmaapp.h"
#include "mobview.h"
#include <plasma/containmentactionspluginsconfig.h>

MobCorona::MobCorona(QObject *parent)
    : Plasma::Corona(parent)
{
    init();
}

void MobCorona::init()
{
    QDesktopWidget *desktop = QApplication::desktop();
    QObject::connect(desktop, SIGNAL(resized(int)), this, SLOT(screenResized(int)));

    Plasma::ContainmentActionsPluginsConfig desktopPlugins;
    desktopPlugins.addPlugin(Qt::NoModifier, Qt::Vertical, "switchdesktop");
    desktopPlugins.addPlugin(Qt::NoModifier, Qt::MidButton, "paste");
    desktopPlugins.addPlugin(Qt::NoModifier, Qt::RightButton, "contextmenu");
    Plasma::ContainmentActionsPluginsConfig panelPlugins;
    panelPlugins.addPlugin(Qt::NoModifier, Qt::RightButton, "contextmenu");

    setContainmentActionsDefaults(Plasma::Containment::DesktopContainment, desktopPlugins);
    setContainmentActionsDefaults(Plasma::Containment::PanelContainment, panelPlugins);
    setContainmentActionsDefaults(Plasma::Containment::CustomPanelContainment, panelPlugins);

    enableAction("lock widgets", false);
}

void MobCorona::loadDefaultLayout()
{
    QString defaultConfig = KStandardDirs::locate("appdata", "plasma-default-layoutrc");
    kDebug()<<"IS THIS FIUCKING CONF EMPTY"<<defaultConfig.isEmpty();
    if (!defaultConfig.isEmpty()) {
        kDebug() << "attempting to load the default layout from:" << defaultConfig;
        loadLayout(defaultConfig);
        return;
    }

    // used to force a save into the config file
    KConfigGroup invalidConfig;

    // FIXME: need to load the Netbook-specific containment
    // passing in an empty string will get us whatever the default
    // containment type is!
    Plasma::Containment* c = addContainmentDelayed(QString());

    if (!c) {
        return;
    }

    c->init();

    KCmdLineArgs *args = KCmdLineArgs::parsedArgs();
    bool isDesktop = args->isSet("desktop");

    if (isDesktop) {
        c->setScreen(0);
    }

    c->setWallpaper("image", "SingleImage");
    c->setFormFactor(Plasma::Planar);
    c->updateConstraints(Plasma::StartupCompletedConstraint);
    c->flushPendingConstraintsEvents();
    c->save(invalidConfig);

    emit containmentAdded(c);

    QVariantList netPanelArgs;
    netPanelArgs << PlasmaApp::self()->mainView()->width();
    c = addContainment("netpanel", netPanelArgs);
    /*
    loadDefaultApplet("systemtray", panel);

    foreach (Plasma::Applet* applet, panel->applets()) {
        applet->init();
        applet->flushPendingConstraintsEvents();
        applet->save(invalidConfig);
    }
    */

    requestConfigSync();
    /*
    foreach (Plasma::Containment *c, containments()) {
        kDebug() << "letting the world know about" << (QObject*)c;
        emit containmentAdded(c);
    }
    */
}

Plasma::Applet *MobCorona::loadDefaultApplet(const QString &pluginName, Plasma::Containment *c)
{
    QVariantList args;
    Plasma::Applet *applet = Plasma::Applet::load(pluginName, 0, args);

    if (applet) {
        c->addApplet(applet);
    }

    return applet;
}

Plasma::Containment *MobCorona::findFreeContainment() const
{
    foreach (Plasma::Containment *cont, containments()) {
        if ((cont->containmentType() == Plasma::Containment::DesktopContainment ||
            cont->containmentType() == Plasma::Containment::CustomContainment) &&
            cont->screen() == -1 && !offscreenWidgets().contains(cont)) {
            return cont;
        }
    }

    return 0;
}

void MobCorona::screenResized(int screen)
{
    int numScreens = QApplication::desktop()->numScreens();
    if (screen < numScreens) {
        foreach (Plasma::Containment *c, containments()) {
            if (c->screen() == screen) {
                // trigger a relayout
                c->setScreen(screen);
            }
        }
    }
}

int MobCorona::numScreens() const
{
    return Kephal::ScreenUtils::numScreens();
}

QRect MobCorona::screenGeometry(int id) const
{
    return Kephal::ScreenUtils::screenGeometry(id);
}

QRegion MobCorona::availableScreenRegion(int id) const
{
    QRegion r(screenGeometry(id));
    MobView *view = PlasmaApp::self()->controlBar();
    if (view) {
        r = r.subtracted(view->geometry());
    }

    return r;
}



#include "mobcorona.moc"

