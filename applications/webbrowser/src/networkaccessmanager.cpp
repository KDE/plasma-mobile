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



// Self Includes
#include "networkaccessmanager.h"
#include "networkaccessmanager.moc"


// KDE Includes
#include <KLocale>
#include <KProtocolManager>

// Qt Includes
#include <QNetworkReply>
#include <QTimer>

#define QL1S(x)  QLatin1String(x)
#define QL1C(x)  QLatin1Char(x)

class NullNetworkReply : public QNetworkReply
{
public:
    NullNetworkReply(const QNetworkRequest &req, QObject* parent = 0)
        : QNetworkReply(parent)
    {
        setRequest(req);
        setUrl(req.url());
        setHeader(QNetworkRequest::ContentLengthHeader, 0);
        setHeader(QNetworkRequest::ContentTypeHeader, "text/plain");
        setError(QNetworkReply::ContentAccessDenied, i18n("Null reply"));
        setAttribute(QNetworkRequest::User, QNetworkReply::ContentAccessDenied);
        QTimer::singleShot(0, this, SIGNAL(finished()));
    }

    virtual void abort() {}
    virtual qint64 bytesAvailable() const
    {
        return 0;
    }

protected:
    virtual qint64 readData(char*, qint64)
    {
        return -1;
    }
};


// ----------------------------------------------------------------------------------------------


NetworkAccessManager::NetworkAccessManager(QObject *parent)
    : AccessManager(parent)
{
    QString c = KGlobal::locale()->language();

    if (c == QL1S("C"))
        c = QL1S("en-US");
    else
        c = c.replace(QL1C('_') , QL1C('-'));

    c.append(QL1S(", en-US; q=0.8, en; q=0.6"));

    _acceptLanguage = c.toLatin1();
}


QNetworkReply *NetworkAccessManager::createRequest(QNetworkAccessManager::Operation op, const QNetworkRequest &request, QIODevice *outgoingData)
{
   /* WebPage *parentPage = qobject_cast<WebPage *>(parent());

    // NOTE: This to get sure we are NOT serving unused requests
    if (!parentPage)
        return new NullNetworkReply(request, this);*/

    QNetworkReply *reply = 0;

    // set our "nice" accept-language header...
    QNetworkRequest req = request;
    req.setRawHeader("Accept-Language", _acceptLanguage);

    // Handle GET operations with AdBlock
    /*if (op == QNetworkAccessManager::GetOperation)
        reply = rApp->adblockManager()->block(req, parentPage);*/

    if (!reply)
        reply = AccessManager::createRequest(op, req, outgoingData);

   /* if (parentPage->hasNetworkAnalyzerEnabled())
        emit networkData(op, req, reply);*/

    return reply;
}
