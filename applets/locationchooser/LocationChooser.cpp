/*
 *   Copyright (C) 2009, 2010 Ivan Cukic <ivan.cukic(at)kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License version 2,
 *   or (at your option) any later version, as published by the Free
 *   Software Foundation
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#include "LocationChooser.h"

#include <QDBusConnection>
#include <QDeclarativeEngine>
#include <QDeclarativeContext>

#include <Plasma/DeclarativeWidget>
#include <KDesktopFile>
#include <KDebug>

#include <config-locationchooser.h>
#include "Engine.h"

class LocationChooser::Private {
public:
    Plasma::DeclarativeWidget * root;
    KDesktopFile * desktop;
    Engine * engine;

    bool initialized : 1;
};

LocationChooser::LocationChooser(QObject * parent, const QVariantList &args)
  : Plasma::PopupApplet(parent, args), d(new Private())
{
    kDebug() << "Location ###";

    d->initialized = false;

    // init();
}

LocationChooser::~LocationChooser()
{
    delete d->desktop;
    delete d->root;
    delete d;
}

void LocationChooser::init()
{
    if (d->initialized) return;

    setPopupIcon("plasmaapplet-location");
    d->initialized = true;

    d->root = new Plasma::DeclarativeWidget(this);
    d->root->setWindowFlags(Qt::Window);
    d->desktop = new KDesktopFile(LOCATION_CHOOSER_PACKAGE_DIR + "metadata.desktop");
    d->engine = new Engine(this);

    // connect(d->engine, SIGNAL(currentLocationChanged(QString,QString)),
    //         this, SLOT(currentLocationChanged(QString,QString)));

    setGraphicsWidget(d->root);
    d->root->setInitializationDelayed(true);
    d->root->engine()->rootContext()->setContextProperty("locationManager", d->engine);

    d->root->setQmlPath(LOCATION_CHOOSER_PACKAGE_DIR + d->desktop->desktopGroup().readEntry("X-Plasma-MainScript"));

    d->engine->init();
}

void LocationChooser::currentLocationChanged(const QString & id, const QString & name)
{
    kDebug() << id << name;
}

void LocationChooser::popupEvent(bool show)
{
    d->engine->requestUiReset();
    Plasma::PopupApplet::popupEvent(show);
}

#include "LocationChooser.moc"
