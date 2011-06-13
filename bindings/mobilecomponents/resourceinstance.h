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
#ifndef RESOURCEINSTANCE_H
#define RESOURCEINSTANCE_H

#include <QObject>
#include <QUrl>

namespace Activities {
    class ResourceInstance;
}

class ResourceInstance : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QUrl uri READ uri WRITE setUri NOTIFY uriChanged)
    Q_PROPERTY(QString mimetype READ mimetype WRITE setMimetype NOTIFY mimetypeChanged)
    //Q_PROPERTY(OpenReason openReason READ openReason)

public:
    ResourceInstance(QObject *parent = 0);
    ~ResourceInstance();

    QUrl uri() const;
    void setUri(const QUrl &uri);

    QString mimetype() const;
    void setMimetype(const QString &mimetype);

Q_SIGNALS:
    void uriChanged();
    void mimetypeChanged();


private:
    Activities::ResourceInstance *m_resourceInstance;
};

#endif
