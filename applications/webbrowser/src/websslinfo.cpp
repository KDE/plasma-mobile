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


// Self Includes
#include "websslinfo.h"

// Qt Includes
#include <QtCore/QVariant>


class WebSslInfo::WebSslInfoPrivate
{
public:
    WebSslInfoPrivate()
        : usedCipherBits(0), supportedCipherBits(0) {}

    QUrl url;
    QString ciphers;
    QString protocol;
    QString certErrors;
    QHostAddress peerAddress;
    QHostAddress parentAddress;
    QList<QSslCertificate> certificateChain;

    int usedCipherBits;
    int supportedCipherBits;
};

WebSslInfo::WebSslInfo()
    : d(new WebSslInfo::WebSslInfoPrivate)
{
}

WebSslInfo::WebSslInfo(const WebSslInfo& other)
    : d(new WebSslInfo::WebSslInfoPrivate)
{
    *this = other;
}

WebSslInfo::~WebSslInfo()
{
    delete d;
    d = 0;
}

bool WebSslInfo::isValid() const
{
    return (d ? !d->peerAddress.isNull() : false);
}

QUrl WebSslInfo::url() const
{
    return (d ? d->url : QUrl());
}

QHostAddress WebSslInfo::parentAddress() const
{
    return (d ? d->parentAddress : QHostAddress());
}

QHostAddress WebSslInfo::peerAddress() const
{
    return (d ? d->peerAddress : QHostAddress());
}

QString WebSslInfo::protocol() const
{
    return (d ? d->protocol : QString());
}

QString WebSslInfo::ciphers() const
{
    return (d ?  d->ciphers : QString());
}

QString WebSslInfo::certificateErrors() const
{
    return (d ?  d->certErrors : QString());
}

int WebSslInfo::supportedChiperBits() const
{
    return (d ? d->supportedCipherBits : 0);
}

int WebSslInfo::usedChiperBits() const
{
    return (d ?  d->usedCipherBits : 0);
}

QList<QSslCertificate> WebSslInfo::certificateChain() const
{
    return (d ? d->certificateChain : QList<QSslCertificate>());
}

WebSslInfo& WebSslInfo::operator=(const WebSslInfo & other)
{
    if (d)
    {
        d->ciphers = other.d->ciphers;
        d->protocol = other.d->protocol;
        d->certErrors = other.d->certErrors;
        d->peerAddress = other.d->peerAddress;
        d->parentAddress = other.d->parentAddress;
        d->certificateChain = other.d->certificateChain;

        d->usedCipherBits = other.d->usedCipherBits;
        d->supportedCipherBits = other.d->supportedCipherBits;
        d->url = other.d->url;
    }

    return *this;
}

bool WebSslInfo::saveTo(QMap<QString, QVariant>& data) const
{
    const bool ok = isValid();
    if (ok)
    {
        data.insert("ssl_in_use", true);
        data.insert("ssl_peer_ip", d->peerAddress.toString());
        data.insert("ssl_parent_ip", d->parentAddress.toString());
        data.insert("ssl_protocol_version", d->protocol);
        data.insert("ssl_cipher", d->ciphers);
        data.insert("ssl_cert_errors", d->certErrors);
        data.insert("ssl_cipher_used_bits", d->usedCipherBits);
        data.insert("ssl_cipher_bits", d->supportedCipherBits);
        QByteArray certChain;
        Q_FOREACH(const QSslCertificate & cert, d->certificateChain)
        certChain += cert.toPem();
        data.insert("ssl_peer_chain", certChain);
    }

    return ok;
}

void WebSslInfo::restoreFrom(const QVariant& value, const QUrl& url)
{
    if (value.isValid() && value.type() == QVariant::Map)
    {
        QMap<QString, QVariant> metaData = value.toMap();
        if (metaData.value("ssl_in_use", false).toBool())
        {
            setCertificateChain(metaData.value("ssl_peer_chain").toByteArray());
            setPeerAddress(metaData.value("ssl_peer_ip").toString());
            setParentAddress(metaData.value("ssl_parent_ip").toString());
            setProtocol(metaData.value("ssl_protocol_version").toString());
            setCiphers(metaData.value("ssl_cipher").toString());
            setCertificateErrors(metaData.value("ssl_cert_errors").toString());
            setUsedCipherBits(metaData.value("ssl_cipher_used_bits").toString());
            setSupportedCipherBits(metaData.value("ssl_cipher_bits").toString());
            setUrl(url);
        }
    }
}

void WebSslInfo::setUrl(const QUrl &url)
{
    if (d)
        d->url = url;
}

void WebSslInfo::setPeerAddress(const QString& address)
{
    if (d)
        d->peerAddress = address;
}

void WebSslInfo::setParentAddress(const QString& address)
{
    if (d)
        d->parentAddress = address;
}

void WebSslInfo::setProtocol(const QString& protocol)
{
    if (d)
        d->protocol = protocol;
}

void WebSslInfo::setCertificateChain(const QByteArray& chain)
{
    if (d)
        d->certificateChain = QSslCertificate::fromData(chain);
}

void WebSslInfo::setCiphers(const QString& ciphers)
{
    if (d)
        d->ciphers = ciphers;
}

void WebSslInfo::setUsedCipherBits(const QString& bits)
{
    if (d)
        d->usedCipherBits = bits.toInt();
}

void WebSslInfo::setSupportedCipherBits(const QString& bits)
{
    if (d)
        d->supportedCipherBits = bits.toInt();
}

void WebSslInfo::setCertificateErrors(const QString& certErrors)
{
    if (d)
        d->certErrors = certErrors;
}
