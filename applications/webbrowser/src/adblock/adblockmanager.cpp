/* ============================================================
*
* This file is a part of the rekonq project
*
* Copyright (C) 2010-2011 by Andrea Diamantini <adjam7 at gmail dot com>
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
#include "adblockmanager.h"
#include "adblockmanager.moc"

// Local Includes
#include "adblocknetworkreply.h"
#include "adblockwidget.h"
//#include "webpage.h"

// KDE Includes
#include <KSharedConfig>
#include <KConfigGroup>
#include <KIO/TransferJob>

// Qt Includes
#include <QUrl>
#include <QWebElement>
#include <QWebPage>
#include <QWebFrame>


AdBlockManager::AdBlockManager(QObject *parent)
    : QObject(parent)
    , _isAdblockEnabled(false)
    , _isHideAdsEnabled(false)
    , _index(0)
{
    loadSettings();
}


AdBlockManager::~AdBlockManager()
{
    _whiteList.clear();
    _blackList.clear();
    _hideList.clear();
}


void AdBlockManager::loadSettings(bool checkUpdateDate)
{
    _index = 0;
    _buffer.clear();

    _hostWhiteList.clear();
    _hostBlackList.clear();
    _whiteList.clear();
    _blackList.clear();
    _hideList.clear();

    //_isAdblockEnabled = ReKonfig::adBlockEnabled();
    _isAdblockEnabled = true;
    kDebug() << "ADBLOCK ENABLED = " << _isAdblockEnabled;

    // no need to load filters if adblock is not enabled :)
    if (!_isAdblockEnabled)
        return;

    // just to be sure..
    //_isHideAdsEnabled = ReKonfig::hideAdsEnabled();
    _isHideAdsEnabled = true;

    // read settings
    KSharedConfig::Ptr config = KSharedConfig::openConfig("adblock", KConfig::SimpleConfig, "appdata");
    KConfigGroup rulesGroup(config, "rules");
    QStringList rules;
    rules = rulesGroup.readEntry("local-rules" , QStringList());
    loadRules(rules);

    // ----------------------------------------------------------
    kWarning() << "FIXME: updates disabled";
    /*
    QDateTime today = QDateTime::currentDateTime();
    QDateTime lastUpdate = ReKonfig::lastUpdate();  //  the day of the implementation.. :)
    int days = ReKonfig::updateInterval();

    if (!checkUpdateDate || today > lastUpdate.addDays(days))
    {
        ReKonfig::setLastUpdate(today);

        updateNextSubscription();
        return;
    }
    */
    // else
    //QStringList titles = ReKonfig::subscriptionTitles();
    QStringList titles; // FIXME
    foreach(const QString & title, titles)
    {
        rules = rulesGroup.readEntry(title + "-rules" , QStringList());
        loadRules(rules);
    }
}


void AdBlockManager::loadRules(const QStringList &rules)
{
    foreach(const QString & stringRule, rules)
    {
        // ! rules are comments
        if (stringRule.startsWith('!'))
            continue;

        // [ rules are ABP info
        if (stringRule.startsWith('['))
            continue;

        // empty rules are just dangerous..
        // (an empty rule in whitelist allows all, in blacklist blocks all..)
        if (stringRule.isEmpty())
            continue;

        // white rules
        if (stringRule.startsWith(QL1S("@@")))
        {
            const QString filter = stringRule.mid(2);
            if (_hostWhiteList.tryAddFilter(filter))
                continue;

            AdBlockRule rule(filter);
            _whiteList << rule;
            continue;
        }

        // hide (CSS) rules
        if (stringRule.startsWith(QL1S("##")))
        {
            _hideList << stringRule.mid(2);
            continue;
        }

        // TODO implement domain-specific hiding
        if (stringRule.contains(QL1S("##")))
            continue;

        if (_hostBlackList.tryAddFilter(stringRule))
            continue;

        AdBlockRule rule(stringRule);
        _blackList << rule;
    }
}


QNetworkReply *AdBlockManager::block(const QNetworkRequest &request, QWebPage *page)
{
    if (!_isAdblockEnabled)
        return 0;

    // we (ad)block just http traffic
    if (request.url().scheme() != QL1S("http"))
        return 0;

    QString urlString = request.url().toString();
    // We compute a lowercase version of the URL so each rule does not
    // have to do it.
    const QString urlStringLowerCase = urlString.toLower();
    const QString host = request.url().host();

    // check white rules before :)
    if (_hostWhiteList.match(host))
    {
        kDebug() << "****ADBLOCK: WHITE RULE (@@) Matched by host matcher: ***********";
        kDebug() << "UrlString:  " << urlString;
        return 0;
    }

    foreach(const AdBlockRule & filter, _whiteList)
    {
        if (filter.match(request, urlString, urlStringLowerCase))
        {
            kDebug() << "****ADBLOCK: WHITE RULE (@@) Matched: ***********";
            kDebug() << "UrlString:  " << urlString;
            return 0;
        }
    }

    // then check the black ones :(
    if (_hostBlackList.match(host))
    {
        kDebug() << "****ADBLOCK: BLACK RULE Matched by host matcher: ***********";
        kDebug() << "UrlString:  " << urlString;
        AdBlockNetworkReply *reply = new AdBlockNetworkReply(request, urlString, this);
        return reply;
    }

    foreach(const AdBlockRule & filter, _blackList)
    {
        if (filter.match(request, urlString, urlStringLowerCase))
        {
            kDebug() << "****ADBLOCK: BLACK RULE Matched: ***********";
            kDebug() << "UrlString:  " << urlString;

            QWebElement document = page->mainFrame()->documentElement();
            QWebElementCollection elements = document.findAll("*");
            foreach(QWebElement el, elements)
            {
                const QString srcAttribute = el.attribute("src");
                if (filter.match(request, srcAttribute, srcAttribute.toLower()))
                {
                    kDebug() << "MATCHES ATTRIBUTE!!!!!";
                    el.setStyleProperty(QL1S("visibility"), QL1S("hidden"));
                    el.setStyleProperty(QL1S("width"), QL1S("0"));
                    el.setStyleProperty(QL1S("height"), QL1S("0"));
                }
            }

            AdBlockNetworkReply *reply = new AdBlockNetworkReply(request, urlString, this);
            return reply;
        }
    }

    // no match
    return 0;
}


void AdBlockManager::applyHidingRules(QWebPage *page)
{
    if (!page)
        return;

    if (!_isAdblockEnabled)
        return;

    if (!_isHideAdsEnabled)
        return;

    QWebElement document = page->mainFrame()->documentElement();

    // HIDE RULES
    foreach(const QString & filter, _hideList)
    {
        QWebElementCollection elements = document.findAll(filter);

        foreach(QWebElement el, elements)
        {
            if (el.isNull())
                continue;
            kDebug() << "Hide element: " << el.localName();
            el.setStyleProperty(QL1S("visibility"), QL1S("hidden"));
            el.removeFromDocument();
        }
    }
}


void AdBlockManager::updateNextSubscription()
{
    //QStringList locations = ReKonfig::subscriptionLocations();
    QStringList locations; // FIXME

    if (_index < locations.size())
    {
        QString urlString = locations.at(_index);
        KUrl subUrl = KUrl(urlString);

        KIO::TransferJob* job = KIO::get(subUrl , KIO::Reload , KIO::HideProgressInfo);
        job->metaData().insert("ssl_no_client_cert", "TRUE");
        job->metaData().insert("ssl_no_ui", "TRUE");
        job->metaData().insert("UseCache", "false");
        job->metaData().insert("cookies", "none");
        job->metaData().insert("no-auth", "true");

        connect(job, SIGNAL(data(KIO::Job*, const QByteArray&)), this, SLOT(subscriptionData(KIO::Job*, const QByteArray&)));
        connect(job, SIGNAL(result(KJob*)), this, SLOT(slotResult(KJob*)));

        return;
    }

    _index = 0;
    _buffer.clear();
}


void AdBlockManager::slotResult(KJob *job)
{
    if (job->error())
        return;

    QList<QByteArray> list = _buffer.split('\n');
    QStringList ruleList;
    foreach(const QByteArray & ba, list)
    {
        ruleList << QString(ba);
    }
    loadRules(ruleList);
    saveRules(ruleList);

    _index++;

    // last..
    updateNextSubscription();
}


void AdBlockManager::subscriptionData(KIO::Job* job, const QByteArray& data)
{
    Q_UNUSED(job)

    if (data.isEmpty())
        return;

    int oldSize = _buffer.size();
    _buffer.resize(_buffer.size() + data.size());
    memcpy(_buffer.data() + oldSize, data.data(), data.size());
}


void AdBlockManager::saveRules(const QStringList &rules)
{
    QStringList cleanedRules;
    foreach(const QString & r, rules)
    {
        if (!r.startsWith('!') && !r.startsWith('[') && !r.isEmpty())
            cleanedRules << r;
    }

    //QStringList titles = ReKonfig::subscriptionTitles();
    QStringList titles;
    QString title = titles.at(_index) + "-rules";

    KSharedConfig::Ptr config = KSharedConfig::openConfig("adblock", KConfig::SimpleConfig, "appdata");
    KConfigGroup cg(config , "rules");
    cg.writeEntry(title, cleanedRules);
}


void AdBlockManager::addSubscription(const QString &title, const QString &location)
{
    //QStringList titles = ReKonfig::subscriptionTitles();
    QStringList titles; // FIXME
    if (titles.contains(title))
        return;

    //QStringList locations = ReKonfig::subscriptionLocations();
    QStringList locations; // FIXME
    if (locations.contains(location))
        return;

    titles << title;
    locations << location;
    /* FIXME
    ReKonfig::setSubscriptionTitles(titles);
    ReKonfig::setSubscriptionLocations(locations);
    */
}


void AdBlockManager::showSettings()
{
    QPointer<KDialog> dialog = new KDialog();
    dialog->setCaption(i18nc("@title:window", "Ad Block Settings"));
    dialog->setButtons(KDialog::Ok | KDialog::Cancel);

    AdBlockWidget widget;
    dialog->setMainWidget(&widget);
    connect(dialog, SIGNAL(okClicked()), &widget, SLOT(save()));
    connect(dialog, SIGNAL(okClicked()), this, SLOT(loadSettings()));
    dialog->exec();

    dialog->deleteLater();
}
