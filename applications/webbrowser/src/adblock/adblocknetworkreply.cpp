/* ============================================================
 *
 * This file is a part of the rekonq project
 *
 * Copyright (c) 2009 by Benjamin C. Meyer <ben@meyerhome.net>
 * Copyright (C) 2010 by Andrea Diamantini <adjam7 at gmail dot com>
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
#include "adblocknetworkreply.h"
#include "adblocknetworkreply.moc"

// KDE Includes
#include <klocalizedstring.h>

// Qt Includes
#include <QtCore/QTimer>
#include <QtCore/QString>

#include <QtNetwork/QNetworkRequest>


AdBlockNetworkReply::AdBlockNetworkReply(const QNetworkRequest &request, const QString &urlString, QObject *parent)
    : QNetworkReply(parent)
{
    setOperation(QNetworkAccessManager::GetOperation);
    setRequest(request);
    setUrl(request.url());
    setError(QNetworkReply::ContentAccessDenied, i18n("Blocked by AdBlockRule: %1", urlString));
    QTimer::singleShot(0, this, SLOT(delayedFinished()));
}


void AdBlockNetworkReply::abort()
{
}


qint64 AdBlockNetworkReply::readData(char *data, qint64 maxSize)
{
    Q_UNUSED(data);
    Q_UNUSED(maxSize);
    return -1;
}


void AdBlockNetworkReply::delayedFinished()
{
    emit error(QNetworkReply::ContentAccessDenied);
    emit finished();
}
