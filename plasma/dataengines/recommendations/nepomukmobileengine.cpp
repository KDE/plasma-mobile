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

#include "nepomukmobileengine.h"
#include "testsource.h"
#include "contour_interface.h"

#include <QDBusPendingCallWatcher>

#include <KDebug>


NepomukMobileTest::NepomukMobileTest(QObject* parent, const QVariantList& args)
    : Plasma::DataEngine(parent, args)
{
    setMinimumPollingInterval(2 * 1000); // 2 seconds minimum

    m_contourIface = new OrgKdeContourRecommendationManagerInterface("org.kde.Contour", "/recommendationmanager",
                                    QDBusConnection::sessionBus());
    if (m_contourIface->isValid()) {

        connect(m_contourIface, SIGNAL(recommendationsChanged(QVariant)) ,this, SLOT(updateRecommendations(QVariant)));


        QDBusMessage message = QDBusMessage::createMethodCall("org.kde.Contour",
                                         "/recommendationmanager", "", "recommendations");

        QDBusPendingCall call = QDBusConnection::sessionBus().asyncCall(message);
        QDBusPendingCallWatcher *watcher = new QDBusPendingCallWatcher(call, this);
        connect(watcher, SIGNAL(finished(QDBusPendingCallWatcher *)), this, SLOT(recommendationsCallback(QDBusPendingCallWatcher *)));

    } else {
        delete m_contourIface;
        m_contourIface = 0;
        kDebug()<<"Contour not reachable";
    }
}

NepomukMobileTest::~NepomukMobileTest()
{
}

void NepomukMobileTest::recommendationsCallback(QDBusPendingCallWatcher *call)
{
    QDBusPendingReply<QVariantMap> reply = *call;
    QVariantMap properties = reply.argumentAt<0>();

    if (reply.isError()) {
        kWarning()<<"Invalid reply";
    } else {
        kWarning()<<"Properties: "<<properties;
        updateRecommendations(properties);
    }
}

void NepomukMobileTest::updateRecommendations(QVariantMap recommendations)
{
    kWarning()<<"Map of recommendations: "<<recommendations;
    /*
    foreach (const QString &service, registeredItems) {
        newItem(service);
    }*/
}

bool NepomukMobileTest::sourceRequestEvent(const QString &name)
{
    if (!name.startsWith("test") ) {
        return false;
    }

    updateSourceEvent(name); //start a download
    return true;
}


bool NepomukMobileTest::updateSourceEvent(const QString &name)
{
    kDebug() << name;


    TestSource *source = dynamic_cast<TestSource*>(containerForSource(name));

    if (!source) {
        source = new TestSource(this);
        source->setObjectName(name);

        addSource(source);
    }


    source->update();
    return false;
}

#include "nepomukmobileengine.moc"
