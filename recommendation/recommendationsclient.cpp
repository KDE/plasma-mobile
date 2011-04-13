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
    void updateRecommendations(const QList<Contour::Recommendation*> &recommendations);

    RecommendationsClient *q;
    OrgKdeContourRecommendationManagerInterface *contourIface;
    QList<Contour::Recommendation*> recommendations;
};

RecommendationsClient::RecommendationsClient(QObject* parent)
    : QObject(parent),
      d(new RecommendationsClientPrivate(this))
{
    d->contourIface = new OrgKdeContourRecommendationManagerInterface("org.kde.Contour", "/recommendationmanager",
                                    QDBusConnection::sessionBus());
    if (d->contourIface->isValid()) {

        connect(d->contourIface, SIGNAL(recommendationsChanged(const QList<Contour::Recommendation*> &)) ,this, SLOT(updateRecommendations(const QList<Contour::Recommendation*> &)));


        QDBusMessage message = QDBusMessage::createMethodCall("org.kde.Contour",
                                         "/recommendationmanager", "", "recommendations");

        QDBusPendingCall call = QDBusConnection::sessionBus().asyncCall(message);
        QDBusPendingCallWatcher *watcher = new QDBusPendingCallWatcher(call, this);
        connect(watcher, SIGNAL(finished(QDBusPendingCallWatcher *)), this, SLOT(recommendationsCallback(QDBusPendingCallWatcher *)));

    } else {
        delete d->contourIface;
        d->contourIface = 0;
        kWarning() << "Contour not reachable";
    }
}

RecommendationsClient::~RecommendationsClient()
{
}

void RecommendationsClientPrivate::recommendationsCallback(QDBusPendingCallWatcher *call)
{
    QDBusPendingReply<QVariantMap> reply = *call;
    const QVariantMap properties = reply.argumentAt<0>();

    if (reply.isError()) {
        kWarning()<<"Invalid reply";
    } else {
        kWarning()<<"Properties: "<<properties;
        //updateRecommendations(properties);
    }
}

void RecommendationsClientPrivate::updateRecommendations(const QList<Contour::Recommendation*> &newRecommendations)
{
    kWarning()<<"Map of recommendations: "<<recommendations;
    recommendations = newRecommendations;
    emit q->recommendationsChanged(newRecommendations);
}

}

#include "recommendationsclient.moc"
