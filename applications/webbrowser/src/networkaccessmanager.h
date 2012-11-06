/* ============================================================
*
* This file is a part of the rekonq project
*
* Copyright (C) 2007-2008 Trolltech ASA. All rights reserved
* Copyright (C) 2008-2012 by Andrea Diamantini <adjam7 at gmail dot com>
*
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public License as
* published by the Free Software Foundation; either version 2 of
* the License or (at your option) version 3 or any later version
* accepted by the membership of KDE e.V. (or its successor approved
* by the membership of KDE e.V.), which shall act as a proxy
* defined in Section 14 of version 3 of the license.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this program.  If not, see <http://www.gnu.org/licenses/>.
*
* ============================================================ */


#ifndef NETWORKACCESSMANAGER_H
#define NETWORKACCESSMANAGER_H



// KDE Includes
#include <KIO/AccessManager>

// Qt Includes
#include <QByteArray>


class NetworkAccessManager : public KIO::Integration::AccessManager
{
    Q_OBJECT

public:
    NetworkAccessManager(QObject *parent);

protected:
    virtual QNetworkReply *createRequest(QNetworkAccessManager::Operation op, const QNetworkRequest &request, QIODevice *outgoingData = 0);

Q_SIGNALS:
    void networkData(QNetworkAccessManager::Operation op, const QNetworkRequest &request, QNetworkReply *reply);

private:
    QByteArray _acceptLanguage;
};

#endif // NETWORKACCESSMANAGER_H
