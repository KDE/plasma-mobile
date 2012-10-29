/* ============================================================
*
* This file is a part of the KDE project
*
* Copyright (C) 2009-2011 by Dawit Alemayehu <adawit@kde.org>
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


#ifndef WEBSSLINFO_H
#define WEBSSLINFO_H

#include <kdemacros.h>

#include <QtCore/QUrl>
#include <QtCore/QList>
#include <QtCore/QString>
#include <QtNetwork/QHostAddress>
#include <QtNetwork/QSslCertificate>


class WebSslInfo
{
public:
    WebSslInfo();
    WebSslInfo(const WebSslInfo&);
    virtual ~WebSslInfo();

    bool isValid() const;
    QUrl url() const;
    QHostAddress peerAddress() const;
    QHostAddress parentAddress() const;
    QString ciphers() const;
    QString protocol() const;
    QString certificateErrors() const;
    int supportedChiperBits() const;
    int usedChiperBits() const;
    QList<QSslCertificate> certificateChain() const;

    bool saveTo(QMap<QString, QVariant>&) const;
    void restoreFrom(const QVariant &, const QUrl& = QUrl());

    void setUrl(const QUrl &url);
    WebSslInfo& operator = (const WebSslInfo&);

protected:
    void setCiphers(const QString& ciphers);
    void setProtocol(const QString& protocol);
    void setPeerAddress(const QString& address);
    void setParentAddress(const QString& address);
    void setCertificateChain(const QByteArray& chain);
    void setCertificateErrors(const QString& certErrors);
    void setUsedCipherBits(const QString& bits);
    void setSupportedCipherBits(const QString& bits);

private:
    class WebSslInfoPrivate;
    WebSslInfoPrivate* d;
};

#endif // WEBSSLINFO_H
