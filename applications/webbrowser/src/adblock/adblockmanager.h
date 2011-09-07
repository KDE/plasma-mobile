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



#ifndef ADBLOCK_MANAGER_H
#define ADBLOCK_MANAGER_H


// NOTE: AdBlockPlus Filters (fast) summary
//
// ### Basic Filter rules
//
// RULE = http://example.com/ads/*
// this should block every link containing all things from that link
//
// ### Exception rules (@@)
//
// RULE = @@advice*
//
// this will save every site, also that matched by other rules, cointaining words
// that starts with "advice". Wildcards && regular expression allowed here.
//
// ### Beginning/end matching rules (||)
//
// RULE=||http://badsite.com
//
// will stop all links starting with http://badsite.com
//
// RULE=*swf||
//
// will stop all links to direct flash contents
//
// ### Comments (!)
//
// RULE=!azz..
//
// Every rule starting with a ! is commented out and should not be checked
//
// ### Filter Options
//
// You can also specify a number of options to modify the behavior of a filter.
// You list these options separated with commas after a dollar sign ($) at the end of the filter
//
// RULE=*/ads/*$element,match-case
//
// where $element can be one of the following:
// $script             external scripts loaded via HTML script tag
// $image              regular images, typically loaded via HTML img tag
// $background         background images, often specified via CSS
// $stylesheet         external CSS stylesheet files
// $object             content handled by browser plugins, e.g. Flash or Java
// $xbl                XBL bindings (typically loaded by -moz-binding CSS property) Firefox 3 or higher required
// $ping               link pings Firefox 3 or higher required
// $xmlhttprequest     requests started by the XMLHttpRequest object Firefox 3 or higher required
// $object-subrequest  requests started plugins like Flash Firefox 3 or higher required
// $dtd                DTD files loaded by XML documents Firefox 3 or higher required
// $subdocument        embedded pages, usually included via HTML frames
// $document           the page itself (only exception rules can be applied to the page)
// $other              types of requests not covered in the list above
//
// Inverse type options are allowed through the ~ sign, for example:
//
// RULE=*/ads/*~$script,match-case
//
// ### Regular expressions
//
// They usually allow to check for (a lot of) sites, using just one rule, but be careful:
// BASIC FILTERS ARE PROCESSED FASTER THAN REGULAR EXPRESSIONS (In ADP! In rekonq, I don't know...)
//
//
// ### ELEMENT HIDING (##)
//
// This is quite different from usual adblock (but, for me, more powerful!). Sometimes you will find advertisements
// that can’t be blocked because they are embedded as text in the web page itself.
// All you can do there is HIDE the element :)
//
// RULE=##div.advise
//
// The previous rule will hide every div whose class is named "advise". Usual CSS selectors apply here :)
//
// END NOTE ----------------------------------------------------------------------------------------------------------


// Local Includes
#include "adblockhostmatcher.h"
#include "adblockrule.h"

// KDE Includes
#include <KConfigGroup>
#include <KIO/Job>

// Qt Includes
#include <QObject>
#include <QNetworkReply>
#include <QStringList>
#include <QByteArray>

// Forward Includes
class QNetworkRequest;
class QWebPage;

// Definitions
typedef QList<AdBlockRule> AdBlockRuleList;


class AdBlockManager : public QObject
{
    Q_OBJECT

public:
    AdBlockManager(QObject *parent = 0);
    ~AdBlockManager();

    QNetworkReply *block(const QNetworkRequest &request, QWebPage *page);
    void applyHidingRules(QWebPage *page);
    void addSubscription(const QString &title, const QString &location);

public slots:
    void loadSettings(bool checkUpdateDate = true);
    //void showSettings();

private:
    void updateNextSubscription();
    void saveRules(const QStringList &);
    void loadRules(const QStringList &);

private slots:
    void slotResult(KJob *);
    void subscriptionData(KIO::Job*, const QByteArray&);

private:
    KConfigGroup _config;
    bool _isAdblockEnabled;
    bool _isHideAdsEnabled;

    AdBlockHostMatcher _hostBlackList;
    AdBlockHostMatcher _hostWhiteList;
    AdBlockRuleList _blackList;
    AdBlockRuleList _whiteList;
    QStringList _hideList;

    int _index;
    QByteArray _buffer;
};

#endif
