/*
 * This file is a part of the rekonq project
 *
 * Copyright (c) 2009 by Benjamin C. Meyer <ben@meyerhome.net>
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


#ifndef ADBLOCKRULE_H
#define ADBLOCKRULE_H

#include "adblockruleimpl.h"
#include <KDebug>
#include <QSharedPointer>

// Forward Includes
class QNetworkRequest;
class QString;


enum RuleTypes
{
    TextRule,
    FallbackRule,
    NullRule
};


class AdBlockRule
{
public:
    AdBlockRule(const QString &filter);

    bool match(const QNetworkRequest &request, const QString &encodedUrl, const QString &encodedUrlLowerCase) const
    {
        Q_ASSERT(encodedUrl.toLower() == encodedUrlLowerCase);
        bool b = m_implementation->match(request, encodedUrl, encodedUrlLowerCase);
        if (b)
        {
            kDebug() << m_implementation->ruleType() << ": rule string = " << m_implementation->ruleString();
        }
        return b;
    }

    static RuleTypes ruleType(const QString &filter);

private:
    QSharedPointer<AdBlockRuleImpl> m_implementation;
};


#endif // ADBLOCKRULE_H
