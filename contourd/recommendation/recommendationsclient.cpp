/*
 *   Copyright (C) 2010 Marco Martin <mart@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License version 2 as
 *   published by the Free Software Foundation
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

#include "recommendationsclient.h"
#include "recommendation.h"
#include "contour_interface.h"

#include <QDBusPendingCallWatcher>

#include <KDebug>

namespace Contour {

class RecommendationsClientPrivate
{
public:
    RecommendationsClientPrivate(RecommendationsClient *client)
        : q(client)
    {}

    void recommendationsCallback(QDBusPendingCallWatcher *call);
    void updateRecommendations(const QList<Contour::Recommendation> &recommendations);
    void connectToContour();
    void serviceChange(const QString& name, const QString& oldOwner, const QString& newOwner);

    RecommendationsClient *q;
    OrgKdeContourRecommendationManagerInterface *contourIface;
    QList<Contour::Recommendation> recommendations;
};

RecommendationsClient::RecommendationsClient(QObject* parent)
    : QObject(parent),
      d(new RecommendationsClientPrivate(this))
{
    qDBusRegisterMetaType<QList<Contour::Recommendation> >();
    qDBusRegisterMetaType<Contour::Recommendation>();
    qDBusRegisterMetaType<Contour::RecommendationAction*>();

    d->connectToContour();

    //the Contour service can come and go..
    QDBusServiceWatcher *watcher = new QDBusServiceWatcher("org.kde.Contour", QDBusConnection::sessionBus(),
                                             QDBusServiceWatcher::WatchForOwnerChange, this);
    connect(watcher, SIGNAL(serviceOwnerChanged(QString,QString,QString)),
            this, SLOT(serviceChange(QString,QString,QString)));
}

RecommendationsClient::~RecommendationsClient()
{
    delete d;
}

void RecommendationsClientPrivate::recommendationsCallback(QDBusPendingCallWatcher *call)
{
    QDBusPendingReply<QVariantMap> reply = *call;

    if (reply.isError()) {
        kWarning()<<"Invalid reply";
    } else {
        QVariantMap properties = reply.argumentAt<0>();
        const QList<Contour::Recommendation> recommendations = (properties.value("recommendations")).value<QList<Contour::Recommendation> >();
        kWarning()<<"Properties: "<<properties;
        updateRecommendations(recommendations);
    }
}

void RecommendationsClientPrivate::updateRecommendations(const QList<Contour::Recommendation> &newRecommendations)
{
//    kWarning()<<"Map of recommendations: "<<recommendations;
    recommendations = newRecommendations;
    emit q->recommendationsChanged(newRecommendations);
}

void RecommendationsClientPrivate::connectToContour()
{
    contourIface = new OrgKdeContourRecommendationManagerInterface("org.kde.Contour", "/recommendationmanager",
                                    QDBusConnection::sessionBus());
    if (contourIface->isValid()) {
        QDBusMessage message = QDBusMessage::createMethodCall(
                                            contourIface->service(),
                                            contourIface->path(),
                                            "org.freedesktop.DBus.Properties",
                                            "Get");

        message << contourIface->interface();
        message << "recommendations";
        QDBusPendingCall call = contourIface->connection().asyncCall(message);
        QDBusPendingCallWatcher *watcher = new QDBusPendingCallWatcher(call, q);
        QObject::connect(watcher, SIGNAL(finished(QDBusPendingCallWatcher *)), q, SLOT(recommendationsCallback(QDBusPendingCallWatcher *)));
    } else {
        delete contourIface;
        contourIface = 0;
        kWarning() << "Contour not reachable";
    }
}

void RecommendationsClientPrivate::serviceChange(const QString& name, const QString& oldOwner, const QString& newOwner)
{
    kDebug()<< "Service" << name << "status change, old owner:" << oldOwner << "new:" << newOwner;

    if (newOwner.isEmpty()) {
        //unregistered
        delete contourIface;
        contourIface = 0;
    } else if (oldOwner.isEmpty()) {
        //registered
        connectToContour();
    }
}

}

#include "recommendationsclient.moc"
