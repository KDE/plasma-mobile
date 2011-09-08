/*
 *   Copyright (C) 2011 Marco Martin <mart@kde.org>
 *   Copyright (C) 2011 Ivan Cukic <ivan.cukic(at)kde.org>
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

#include "RecommendationManager.h"
#include "RecommendationItem.h"

#include <QDBusInterface>
#include <QDBusConnection>
#include <QDBusPendingCall>
#include <QDBusServiceWatcher>

#include <KDebug>

#define CONTOUR_DBUS_PATH "org.kde.Contour"

namespace Contour {

RecommendationManager * RecommendationManager::s_instance = NULL;

RecommendationManager * RecommendationManager::self()
{
    if (!s_instance) {
        s_instance = new RecommendationManager();
    }

    return s_instance;
}

class RecommendationManager::Private {
public:
    QDBusInterface * iface;

};

RecommendationManager::RecommendationManager()
    : d(new Private())
{
    d->iface = new QDBusInterface(
            CONTOUR_DBUS_PATH,
            "/recommendationmanager",
            "org.kde.contour.RecommendationManager",
            QDBusConnection::sessionBus()
        );

    connect(d->iface, SIGNAL(recommendationsChanged()),
            this, SLOT(updateRecommendations()));

    QDBusServiceWatcher * watcher = new QDBusServiceWatcher(
            CONTOUR_DBUS_PATH,
            QDBusConnection::sessionBus(),
            QDBusServiceWatcher::WatchForRegistration | QDBusServiceWatcher::WatchForUnregistration,
            this
        );

    connect(watcher, SIGNAL(serviceRegistered(QString)),
            this,    SLOT(serviceRegistered(QString)));
    connect(watcher, SIGNAL(serviceUnregistered(QString)),
            this,    SLOT(serviceUnregistered(QString)));

    updateRecommendations();
}

RecommendationManager::~RecommendationManager()
{
    delete d;
}

void RecommendationManager::executeAction(const QString & engine, const QString & id, const QString & action)
{
    d->iface->asyncCall("executeAction", engine, id, action);
}

void RecommendationManager::updateRecommendations()
{
    kDebug() << "Requesting a new list of recommendations";

    d->iface->callWithCallback("recommendations", QList<QVariant>(),
                            this, SLOT(updateRecommendationsFinished(QDBusMessage)));
}

void RecommendationManager::updateRecommendationsFinished(const QDBusMessage & message)
{
    kDebug() << message << message.arguments() << message.arguments().size();


    foreach (const QVariant & argument, message.arguments()) {
        QDBusArgument result = argument.value < QDBusArgument > ();

        QList < RecommendationItem > recommendations =
            qdbus_cast < QList < RecommendationItem > > (result);

        emit recommendationsChanged(recommendations);
    }
}

void RecommendationManager::serviceRegistered(const QString & service)
{
    if (service != CONTOUR_DBUS_PATH) return;

    updateRecommendations();
}

void RecommendationManager::serviceUnregistered(const QString & service)
{
    if (service != CONTOUR_DBUS_PATH) return;

    QList < RecommendationItem > recommendations;
    emit recommendationsChanged(recommendations);
}

} // namespace Contour

// class RecommendationManager


