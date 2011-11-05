/***************************************************************************
 *   Copyright 2011 Marco Martin <mart@kde.org>                            *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU Library General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU Library General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU Library General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA .        *
 ***************************************************************************/
#ifndef RESOURCEINSTANCE_H
#define RESOURCEINSTANCE_H

#include <QDeclarativeItem>
#include <QUrl>

namespace KActivities {
    class ResourceInstance;
}

class QTimer;
class QGraphicsView;

class ResourceInstance : public QDeclarativeItem
{
    Q_OBJECT

    Q_PROPERTY(QUrl uri READ uri WRITE setUri NOTIFY uriChanged)
    Q_PROPERTY(QString mimetype READ mimetype WRITE setMimetype NOTIFY mimetypeChanged)
    Q_PROPERTY(QString title READ title WRITE setTitle NOTIFY titleChanged)
    //Q_PROPERTY(OpenReason openReason READ openReason)

public:
    ResourceInstance(QDeclarativeItem *parent = 0);
    ~ResourceInstance();

    QUrl uri() const;
    void setUri(const QUrl &uri);

    QString mimetype() const;
    void setMimetype(const QString &mimetype);

    QString title() const;
    void setTitle(const QString &title);

protected:
    QGraphicsView *view() const;

protected Q_SLOTS:
    void syncWid();

Q_SIGNALS:
    void uriChanged();
    void mimetypeChanged();
    void titleChanged();

public Q_SLOTS:
    /**
     * Call this method to notify the system that you modified
     * (the contents of) the resource
     */
    void notifyModified();

    /**
     * Call this method to notify the system that the resource
     * has the focus in your application
     * @note You only need to call this in MDI applications
     */
    void notifyFocusedIn();

    /**
     * Call this method to notify the system that the resource
     * lost the focus in your application
     * @note You only need to call this in MDI applications
     */
    void notifyFocusedOut();

private:
    KActivities::ResourceInstance *m_resourceInstance;
    QUrl m_uri;
    QString m_mimetype;
    QString m_title;
    QTimer *m_syncTimer;
};

#endif
