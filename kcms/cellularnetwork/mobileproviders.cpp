/*
    SPDX-FileCopyrightText: 2010-2012 Lamarque Souza <lamarque@kde.org>

    SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
*/

#include "mobileproviders.h"

#include <QDebug>
#include <QFile>
#include <QLocale>
#include <QRegularExpression>
#include <QTextStream>

const QString MobileProviders::ProvidersFile = QStringLiteral("/usr/share/mobile-broadband-provider-info/serviceproviders.xml");

// adapted from https://invent.kde.org/plasma/plasma-nm/-/blob/master/libs/editor/mobileproviders.cpp
// we only use gsm, ignore cdma

bool localeAwareCompare(const QString &one, const QString &two)
{
    return one.localeAwareCompare(two) < 0;
}

MobileProviders::MobileProviders()
{
    for (int c = 1; c <= QLocale::LastCountry; c++) {
        const auto country = static_cast<QLocale::Territory>(c);
        QLocale locale(QLocale::AnyLanguage, country);
        if (locale.territory() == country) {
            const QString localeName = locale.name();
            const auto idx = localeName.indexOf(QLatin1Char('_'));
            if (idx != -1) {
                const QString countryCode = localeName.mid(idx + 1);
                QString countryName = locale.nativeTerritoryName();
                if (countryName.isEmpty()) {
                    countryName = QLocale::territoryToString(country);
                }
                mCountries.insert(countryCode, countryName);
            }
        }
    }
    mError = Success;

    QFile file2(ProvidersFile);

    if (file2.open(QIODevice::ReadOnly)) {
        if (mDocProviders.setContent(&file2)) {
            docElement = mDocProviders.documentElement();

            if (docElement.isNull()) {
                qWarning() << ProvidersFile << ": document is null";
                mError = ProvidersIsNull;
            } else {
                if (docElement.isNull() || docElement.tagName() != "serviceproviders") {
                    qWarning() << ProvidersFile << ": wrong format";
                    mError = ProvidersWrongFormat;
                } else {
                    if (docElement.attribute("format") != "2.0") {
                        qWarning() << ProvidersFile << ": mobile broadband provider database format '" << docElement.attribute("format") << "' not supported.";
                        mError = ProvidersFormatNotSupported;
                    } else {
                        // qCDebug(PLASMA_NM) << "Everything is alright so far";
                    }
                }
            }
        }

        file2.close();
    } else {
        qWarning() << "Error opening providers file" << ProvidersFile;
        mError = ProvidersMissing;
    }
}

MobileProviders::~MobileProviders()
{
}

QStringList MobileProviders::getCountryList() const
{
    QStringList temp = mCountries.values();
    std::sort(temp.begin(), temp.end(), localeAwareCompare);
    return temp;
}

QString MobileProviders::countryFromLocale() const
{
    const QString localeName = QLocale().name();
    const auto idx = localeName.indexOf(QLatin1Char('_'));
    if (idx != -1) {
        return localeName.mid(idx + 1);
    }
    return QString();
}

QStringList MobileProviders::getApns(const QString &provider)
{
    mApns.clear();
    mNetworkIds.clear();
    if (!mProvidersGsm.contains(provider)) {
        return QStringList();
    }

    QDomNode n = mProvidersGsm[provider];

    while (!n.isNull()) {
        QDomElement e = n.toElement(); // <gsm | cdma>

        if (!e.isNull() && e.tagName().toLower() == "gsm") {
            QDomNode n2 = e.firstChild();
            while (!n2.isNull()) {
                QDomElement e2 = n2.toElement(); // <apn | network-id>

                if (!e2.isNull() && e2.tagName().toLower() == "apn") {
                    bool isInternet = true;
                    QDomNode n3 = e2.firstChild();
                    while (!n3.isNull()) {
                        QDomElement e3 = n3.toElement(); // <usage>
                        if (!e3.isNull() && e3.tagName().toLower() == "usage" && !e3.attribute("type").isNull()
                            && e3.attribute("type").toLower() != "internet") {
                            // qCDebug(PLASMA_NM) << "apn" << e2.attribute("value") << "ignored because of usage" << e3.attribute("type");
                            isInternet = false;
                            break;
                        }
                        n3 = n3.nextSibling();
                    }
                    if (isInternet) {
                        mApns.insert(e2.attribute("value"), e2.firstChild());
                    }
                } else if (!e2.isNull() && e2.tagName().toLower() == "network-id") {
                    mNetworkIds.append(e2.attribute("mcc") + '-' + e2.attribute("mnc"));
                }

                n2 = n2.nextSibling();
            }
        }
        n = n.nextSibling();
    }

    QStringList temp = mApns.keys();
    temp.sort();
    return temp;
}

ProviderData MobileProviders::parseProvider(const QDomNode &providerNode)
{
    ProviderData result;

    QMap<QString, QString> localizedProviderNames;

    QDomNode c = providerNode.firstChild(); // <name | gsm | cdma>
    bool hasGsm = false;

    while (!c.isNull()) {
        QDomElement ce = c.toElement();

        if (ce.tagName().toLower() == QLatin1String("gsm")) {
            QDomNode gsmNode = c.firstChild();

            while (!gsmNode.isNull()) {
                QDomElement gsmElement = gsmNode.toElement();

                if (gsmElement.tagName().toLower() == QLatin1String("network-id")) {
                    result.mccmncs.append(gsmElement.attribute("mcc") + gsmElement.attribute("mnc"));
                }
                gsmNode = gsmNode.nextSibling();
            }

            hasGsm = true;
        } else if (ce.tagName().toLower() == QLatin1String("name")) {
            QString lang = ce.attribute("xml:lang");
            if (lang.isEmpty()) {
                lang = "en"; // English is default
            } else {
                lang = lang.toLower();
                lang.remove(QRegularExpression(QStringLiteral("\\-.*$"))); // Remove everything after '-' in xml:lang attribute.
            }
            localizedProviderNames.insert(lang, ce.text());
        }

        c = c.nextSibling();
    }

    result.name = getNameByLocale(localizedProviderNames);

    const QString name = result.name;
    if (hasGsm) {
        mProvidersGsm.insert(name, providerNode.firstChild());
    }

    return result;
}

QStringList MobileProviders::getProvidersFromMCCMNC(const QString &targetMccMnc)
{
    QStringList result;

    QDomNode n = docElement.firstChild();

    while (!n.isNull()) {
        QDomElement e = n.toElement(); // <country ...>

        if (!e.isNull()) {
            QDomNode n2 = e.firstChild();
            while (!n2.isNull()) {
                QDomElement e2 = n2.toElement(); // <provider ...>

                if (!e2.isNull() && e2.tagName().toLower() == "provider") {
                    ProviderData data = parseProvider(e2);

                    if (data.mccmncs.contains(targetMccMnc)) {
                        result << data.name;
                    }
                }
                n2 = n2.nextSibling();
            }
        }
        n = n.nextSibling();
    }

    return result;
}

QStringList MobileProviders::getNetworkIds(const QString &provider)
{
    if (mNetworkIds.isEmpty()) {
        getApns(provider);
    }
    return mNetworkIds;
}

QVariantMap MobileProviders::getApnInfo(const QString &apn)
{
    QVariantMap temp;
    QDomNode n = mApns[apn];
    QStringList dnsList;
    QMap<QString, QString> localizedPlanNames;

    while (!n.isNull()) {
        QDomElement e = n.toElement(); // <name|username|password|dns(*)>

        if (!e.isNull()) {
            if (e.tagName().toLower() == "name") {
                QString lang = e.attribute("xml:lang");
                if (lang.isEmpty()) {
                    lang = "en"; // English is default
                } else {
                    lang = lang.toLower();
                    lang.remove(QRegularExpression(QStringLiteral("\\-.*$"))); // Remove everything after '-' in xml:lang attribute.
                }
                localizedPlanNames.insert(lang, e.text());
            } else if (e.tagName().toLower() == "username") {
                temp.insert("username", e.text());
            } else if (e.tagName().toLower() == "password") {
                temp.insert("password", e.text());
            } else if (e.tagName().toLower() == "dns") {
                dnsList.append(e.text());
            } else if (e.tagName().toLower() == "usage") {
                temp.insert("usageType", e.attribute("type"));
            }
        }

        n = n.nextSibling();
    }

    QString name = getNameByLocale(localizedPlanNames);
    if (!name.isEmpty()) {
        temp.insert("name", QVariant::fromValue(name));
    }
    temp.insert("number", getGsmNumber());
    temp.insert("apn", apn);
    temp.insert("dnsList", dnsList);

    return temp;
}

QVariantMap MobileProviders::getCdmaInfo(const QString &provider)
{
    if (!mProvidersCdma.contains(provider)) {
        return QVariantMap();
    }

    QVariantMap temp;
    QDomNode n = mProvidersCdma[provider];
    QStringList sidList;

    while (!n.isNull()) {
        QDomElement e = n.toElement(); // <gsm or cdma ...>

        if (!e.isNull() && e.tagName().toLower() == "cdma") {
            QDomNode n2 = e.firstChild();
            while (!n2.isNull()) {
                QDomElement e2 = n2.toElement(); // <name | username | password | sid>

                if (!e2.isNull()) {
                    if (e2.tagName().toLower() == "username") {
                        temp.insert("username", e2.text());
                    } else if (e2.tagName().toLower() == "password") {
                        temp.insert("password", e2.text());
                    } else if (e2.tagName().toLower() == "sid") {
                        sidList.append(e2.text());
                    }
                }

                n2 = n2.nextSibling();
            }
        }
        n = n.nextSibling();
    }

    temp.insert("number", getCdmaNumber());
    temp.insert("sidList", sidList);
    return temp;
}

QString MobileProviders::getNameByLocale(const QMap<QString, QString> &localizedNames) const
{
    QString name;
    const QStringList locales = QLocale().uiLanguages();
    for (const QString &locale : locales) {
        QString language = locale.split(QLatin1Char('-')).at(0);

        if (localizedNames.contains(language)) {
            return localizedNames[language];
        }
    }

    name = localizedNames["en"];

    // Use any language if no proper localized name were found.
    if (name.isEmpty() && !localizedNames.isEmpty()) {
        name = localizedNames.constBegin().value();
    }
    return name;
}
