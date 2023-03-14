/*
    SPDX-FileCopyrightText: 2010-2012 Lamarque Souza <lamarque@kde.org>

    SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
*/

#ifndef PLASMA_NM_MOBILE_PROVIDERS_H
#define PLASMA_NM_MOBILE_PROVIDERS_H

#include <QDomDocument>
#include <QHash>
#include <QStringList>
#include <QVariantMap>

#include <NetworkManagerQt/ConnectionSettings>

// adapted from https://invent.kde.org/plasma/plasma-nm/-/blob/master/libs/editor/mobileproviders.h
// we only use gsm, ignore cdma

struct ProviderData {
    QStringList mccmncs;
    QString name;
};

class Q_DECL_EXPORT MobileProviders
{
public:
    static const QString ProvidersFile;

    enum ErrorCodes {
        Success,
        CountryCodesMissing,
        ProvidersMissing,
        ProvidersIsNull,
        ProvidersWrongFormat,
        ProvidersFormatNotSupported,
    };

    MobileProviders();
    ~MobileProviders();

    QStringList getCountryList() const;
    QString countryFromLocale() const;
    QString getCountryName(const QString &key) const
    {
        return mCountries.value(key);
    }
    QStringList getApns(const QString &provider);
    QStringList getNetworkIds(const QString &provider);
    QVariantMap getApnInfo(const QString &apn);
    QVariantMap getCdmaInfo(const QString &provider);
    QStringList getProvidersFromMCCMNC(const QString &mccmnc);
    QString getGsmNumber() const
    {
        return QString("*99#");
    }
    QString getCdmaNumber() const
    {
        return QString("#777");
    }
    inline ErrorCodes getError()
    {
        return mError;
    }

private:
    ProviderData parseProvider(const QDomNode &providerNode);

    QHash<QString, QString> mCountries;
    QHash<QString, QString> mMccMncToName;
    QMap<QString, QDomNode> mProvidersGsm;
    QMap<QString, QDomNode> mProvidersCdma;
    QMap<QString, QDomNode> mApns;
    QStringList mNetworkIds;
    QDomDocument mDocProviders;
    QDomElement docElement;
    ErrorCodes mError;
    QString getNameByLocale(const QMap<QString, QString> &names) const;
};

#endif // PLASMA_NM_MOBILE_PROVIDERS_H
