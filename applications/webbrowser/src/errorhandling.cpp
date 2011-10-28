/* ============================================================
*
* This file is kindly borrowed from the rekonq project
*
* Copyright (C) 2008 Benjamin C. Meyer <ben@meyerhome.net>
* Copyright (C) 2008 Dirk Mueller <mueller@kde.org>
* Copyright (C) 2008 Urs Wolfer <uwolfer @ kde.org>
* Copyright (C) 2008 Michael Howell <mhowell123@gmail.com>
* Copyright (C) 2008-2011 by Andrea Diamantini <adjam7 at gmail dot com>
* Copyright (C) 2010 by Matthieu Gicquel <matgic78 at gmail dot com>
* Copyright (C) 2009-2010 Dawit Alemayehu <adawit at kde dot org>
* Copyright 2011 Sebastian Kügler <sebas@kde.org>
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

#include <KStandardDirs>
#include <QtCore/qnamespace.h>
#include <QTextDocument>

void QDeclarativeWebPage::handleNetworkErrors(QNetworkReply *reply)
{
    Q_ASSERT(reply);

    QWebFrame* frame = qobject_cast<QWebFrame *>(reply->request().originatingObject());
    if (!frame->url().isEmpty() && frame->url() != reply->url()) {
        // it's an error for a part of the page, not the page itself; we don't want to
        // reset the whole page due to this; just let it fail silently
        return;
    }

    // NOTE: These are not all networkreply errors,
    // but just that supported directly by KIO
    switch (reply->error())
    {

    case QNetworkReply::NoError:                             // no error, nothing to do here.
        break;

    case QNetworkReply::OperationCanceledError:              // operation canceled via abort() or close() calls
        // ignore this..
        return;

    case QNetworkReply::ContentAccessDenied:                 // access to remote content denied (similar to HTTP error 401)
        kDebug() << "We (hopefully) are managing this through the adblock :)";
        break;

    case QNetworkReply::UnknownNetworkError:                 // unknown network-related error detected
        kDebug() << "------------------ DO WE REALLY NEED THIS??? --------------------";
        //_protHandler.postHandling(reply->request(), frame);
        return;

    case QNetworkReply::ConnectionRefusedError:              // remote server refused connection
    case QNetworkReply::HostNotFoundError:                   // invalid hostname
    case QNetworkReply::TimeoutError:                        // connection time out
    case QNetworkReply::ProxyNotFoundError:                  // invalid proxy hostname
    case QNetworkReply::ContentOperationNotPermittedError:   // operation requested on remote content not permitted
    case QNetworkReply::ContentNotFoundError:                // remote content not found on server (similar to HTTP error 404)
    case QNetworkReply::ProtocolUnknownError:                // Unknown protocol
    case QNetworkReply::ProtocolInvalidOperationError:       // requested operation is invalid for this protocol

        kDebug() << "ERROR " << reply->error() << ": " << reply->errorString();
        frame->setHtml(errorPage(reply));
        break;

    default:
        // Nothing to do here..
        break;

    }
}


QString QDeclarativeWebPage::errorPage(QNetworkReply *reply)
{
    // display "not found" page
    QString notfoundFilePath =  KStandardDirs::locate("data", "active-webbrowser/infopage.html");
    QFile file(notfoundFilePath);

    bool isOpened = file.open(QIODevice::ReadOnly);
    if (!isOpened)
    {
        return QString("Couldn't open the infopage.html.");
    }

    QString title = i18n("There was a problem while loading the page");

    // NOTE:
    // this, to take care about XSS (see BUG 217464)...
    QString urlString = Qt::escape(reply->url().toString());
    //QString urlString = QString::htmlEsscape(reply->url().toString());

    QString iconPath = QString("file://") + KIconLoader::global()->iconPath("dialog-warning" , KIconLoader::Small);
    iconPath.replace(QL1S("16"), QL1S("128"));

    QString msg;
    msg += QL1S("<table>");
    msg += QL1S("<tr><td>");
    msg += QL1S("<img src=\"") + iconPath + QL1S("\" />");
    msg += QL1S("</td><td>");
    msg += QL1S("<h1>") + reply->errorString() + QL1S("</h1>");
    msg += QL1S("<h2>") + i18nc("%1=an URL, e.g.'kde.org'", "When connecting to: <b>%1</b>", urlString) + QL1S("</h2>");
    msg += QL1S("</td></tr></table>");

    msg += QL1S("<ul><li>") + i18n("Check the address for errors such as <b>ww</b>.kde.org instead of <b>www</b>.kde.org.");
    msg += QL1S("</li><li>") + i18n("If the address is correct, try to check the network connection.") + QL1S("</li><li>") ;
    msg += i18n("If your computer or network is protected by a firewall or proxy, make sure that access to the network is permitted.");
    msg += QL1S("</li></ul><br/><br/>");
    msg += QL1S("<input type=\"button\" id=\"reloadButton\" onClick=\"document.location.href='") + urlString + QL1S("';\" value=\"");
    msg += i18n("Try Again") + QL1S("\" />");

    QString html = QString(QL1S(file.readAll()))
                   .arg(title)
                   .arg(msg)
                   ;
    return html;
}
