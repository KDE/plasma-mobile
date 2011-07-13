/***************************************************************************
 *   Copyright 2011 Marco Martin <mart@kde.org>                            *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA .        *
 ***************************************************************************/

#include "resourceinstance.h"

#include <QApplication>
#include <QGraphicsObject>
#include <QGraphicsView>
#include <QTimer>

#include <KDE/Activities/ResourceInstance>
#include <KDebug>


ResourceInstance::ResourceInstance(QDeclarativeItem *parent)
    : QDeclarativeItem(parent)
{
    m_syncTimer = new QTimer(this);
    m_syncTimer->setSingleShot(true);
    connect(m_syncTimer, SIGNAL(timeout()), this, SLOT(syncWid()));
}

ResourceInstance::~ResourceInstance()
{

}

QGraphicsView *ResourceInstance::view() const
{
    // It's assumed that we won't be visible on more than one view here.
    // Anything that actually needs view() should only really care about
    // one of them anyway though.
    if (!scene()) {
        return 0;
    }

    QGraphicsView *found = 0;
    QGraphicsView *possibleFind = 0;
    //kDebug() << "looking through" << scene()->views().count() << "views";
    foreach (QGraphicsView *view, scene()->views()) {
        //kDebug() << "     checking" << view << view->sceneRect()
        //         << "against" << sceneBoundingRect() << scenePos();
        if (view->sceneRect().intersects(sceneBoundingRect()) ||
            view->sceneRect().contains(scenePos())) {
            //kDebug() << "     found something!" << view->isActiveWindow();
            if (view->isActiveWindow()) {
                found = view;
            } else {
                possibleFind = view;
            }
        }
    }

    return found ? found : possibleFind;
}

void ResourceInstance::syncWid()
{
    QGraphicsView *v = view();
    if (!v) {
        return;
    }

    WId wid = v->effectiveWinId();
    if (!m_resourceInstance || m_resourceInstance->winId() != wid) {
        delete m_resourceInstance;

        kDebug() << "Creating a new instance of the resource" << m_uri << "window id" << wid;
        m_resourceInstance = new Activities::ResourceInstance(wid, m_uri, m_mimetype);
    } else {
        kDebug() << "Setting" << m_uri << m_mimetype << "to window" << wid;
        m_resourceInstance->setUri(m_uri);
        m_resourceInstance->setMimetype(m_mimetype);
    }
}

QUrl ResourceInstance::uri() const
{
    return m_uri;
}

void ResourceInstance::setUri(const QUrl &uri)
{
    if (m_uri == uri) {
        return;
    }
    m_uri = uri;
    m_syncTimer->start(100);
}

QString ResourceInstance::mimetype() const
{
    return m_mimetype;
}

void ResourceInstance::setMimetype(const QString &mimetype)
{
    if (m_mimetype == mimetype) {
        return;
    }
    m_mimetype = mimetype;
    m_syncTimer->start(100);
}

void ResourceInstance::notifyModified()
{
    //ensure the resource instance exists
    syncWid();
    m_resourceInstance->notifyModified();
}

void ResourceInstance::notifyFocusedIn()
{
    //ensure the resource instance exists
    syncWid();
    m_resourceInstance->notifyFocusedIn();
}


void ResourceInstance::notifyFocusedOut()
{
    //ensure the resource instance exists
    syncWid();
    m_resourceInstance->notifyFocusedOut();
}

#include "resourceinstance.moc"

