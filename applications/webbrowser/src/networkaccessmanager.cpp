/* ============================================================
*
* This file is a part of the rekonq project
*
* Copyright (C) 2007-2008 Trolltech ASA. All rights reserved
* Copyright (C) 2008-2011 by Andrea Diamantini <adjam7 at gmail dot com>
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

#define QL1S(x)  QLatin1String(x)
#define QL1C(x)  QLatin1Char(x)

// Self Includes
#include "networkaccessmanager.h"
#include "networkaccessmanager.moc"

#include "adblockmanager.h"

// Local Includes
#include "adblockmanager.h"
//#include "application.h"
//#include "webpage.h"

// KDE Includes
#include <KLocale>
#include <KProtocolManager>

// Qt Includes
#include <QWebPage>

NetworkAccessManager::NetworkAccessManager(QObject *parent)
    : AccessManager(parent),
    m_adBlockManager(0)
{
    QString c = KGlobal::locale()->country();
    if (c == QL1S("C"))
        c = QL1S("en_US");
    if (c != QL1S("en_US"))
        c.append(QL1S(", en_US"));

    _acceptLanguage = c.toLatin1();
    m_adBlockManager = new AdBlockManager(this);
}

NetworkAccessManager::~NetworkAccessManager()
{
    kDebug() << "AAAA NMA destroyed";
}

void NetworkAccessManager::setAdBlockManager(AdBlockManager* adblocker)
{
    m_adBlockManager = adblocker;
}

QNetworkReply *NetworkAccessManager::createRequest(QNetworkAccessManager::Operation op, const QNetworkRequest &request, QIODevice *outgoingData)
{
    QWebPage *parentPage = qobject_cast<QWebPage *>(parent());
    if (!parentPage) {
        kDebug() << "Page is empty ...";
    }
    QNetworkReply *reply = 0;

    QNetworkRequest req = request;
    req.setAttribute(QNetworkRequest::HttpPipeliningAllowedAttribute, true);
    req.setRawHeader("Accept-Language", _acceptLanguage);

    KIO::CacheControl cc = KProtocolManager::cacheControl();
    switch (cc)
    {
    case KIO::CC_CacheOnly:      // Fail request if not in cache.
        req.setAttribute(QNetworkRequest::CacheLoadControlAttribute, QNetworkRequest::AlwaysCache);
        break;

    case KIO::CC_Refresh:        // Always validate cached entry with remote site.
        req.setAttribute(QNetworkRequest::CacheLoadControlAttribute, QNetworkRequest::PreferNetwork);
        break;

    case KIO::CC_Reload:         // Always fetch from remote site
        req.setAttribute(QNetworkRequest::CacheLoadControlAttribute, QNetworkRequest::AlwaysNetwork);
        break;

    case KIO::CC_Cache:          // Use cached entry if available.
    case KIO::CC_Verify:         // Validate cached entry with remote site if expired.
    default:
        req.setAttribute(QNetworkRequest::CacheLoadControlAttribute, QNetworkRequest::PreferCache);
        break;
    }

    // Handle GET operations with AdBlock
    if (op == QNetworkAccessManager::GetOperation) {
        Q_ASSERT( m_adBlockManager );
        reply = m_adBlockManager->block(req, parentPage);
    }

    if (!reply) {
        reply = AccessManager::createRequest(op, req, outgoingData);
        kDebug() << "AAA request OK";
    } else {
        kDebug() << "AAAA request blocked";
    }
    /*
    if (parentPage && parentPage->hasNetworkAnalyzerEnabled())
        emit networkData(op, req, reply);
    */
    return reply;
}
