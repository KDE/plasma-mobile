/* ============================================================
*
* This file is a part of the rekonq project
*
* Copyright (C) 2010-2011 by Benjamin Poulain <ikipou at gmail dot com>
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
#include "adblockruletextmatchimpl.h"

// Qt Includes
#include <QNetworkRequest>


AdBlockRuleTextMatchImpl::AdBlockRuleTextMatchImpl(const QString &filter)
    : AdBlockRuleImpl(filter)
{
    Q_ASSERT(AdBlockRuleTextMatchImpl::isTextMatchFilter(filter));

    m_textToMatch = filter.toLower();
    m_textToMatch.remove(QL1C('*'));
}


bool AdBlockRuleTextMatchImpl::match(const QNetworkRequest &request, const QString &encodedUrl, const QString &encodedUrlLowerCase) const
{
    // this basically lets the "first request" to pass...
    if (!request.hasRawHeader("referer"))
        return false;

    Q_UNUSED(encodedUrl);
    // Case sensitive compare is faster, but would be incorrect with encodedUrl since
    // we do want case insensitive.
    // What we do is work on a lowercase version of m_textToMatch, and compare to the lowercase
    // version of encodedUrl.
    return encodedUrlLowerCase.contains(m_textToMatch, Qt::CaseSensitive);
}


bool AdBlockRuleTextMatchImpl::isTextMatchFilter(const QString &filter)
{
    // We don't deal with options just yet
    if (filter.contains(QL1C('$')))
        return false;

    // We don't deal with element matching
    if (filter.contains(QL1S("##")))
        return false;

    // We don't deal with the begin-end matching
    if (filter.startsWith(QL1C('|')) || filter.endsWith(QL1C('|')))
        return false;

    // We only handle * at the beginning or the end
    int starPosition = filter.indexOf(QL1C('*'));
    while (starPosition >= 0)
    {
        if (starPosition != 0 && starPosition != (filter.length() - 1))
            return false;
        starPosition = filter.indexOf(QL1C('*'), starPosition + 1);
    }
    return true;
}


QString AdBlockRuleTextMatchImpl::ruleString() const
{
    return m_textToMatch;
}


QString AdBlockRuleTextMatchImpl::ruleType() const
{
    return QL1S("AdBlockRuleTextMatchImpl");
}
