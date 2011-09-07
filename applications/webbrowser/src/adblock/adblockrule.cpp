/* ============================================================
 *
 * This file is a part of the rekonq project
 *
 * Copyright (c) 2009 by Zsombor Gegesy <gzsombor@gmail.com>
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


// Self Includes
#include "adblockrule.h"

// Local Includes
#include "adblockrulefallbackimpl.h"
#include "adblockrulenullimpl.h"
#include "adblockruletextmatchimpl.h"


AdBlockRule::AdBlockRule(const QString &filter)
{
    switch (AdBlockRule::ruleType(filter))
    {
    case TextRule:
        m_implementation = QSharedPointer<AdBlockRuleImpl>(new AdBlockRuleTextMatchImpl(filter));
        break;

    case FallbackRule:
        m_implementation = QSharedPointer<AdBlockRuleImpl>(new AdBlockRuleFallbackImpl(filter));
        break;

    case NullRule:
    default:
        m_implementation = QSharedPointer<AdBlockRuleImpl>(new AdBlockRuleNullImpl(filter));
        break;
    }
}


RuleTypes AdBlockRule::ruleType(const QString &filter)
{
    if (AdBlockRuleTextMatchImpl::isTextMatchFilter(filter))
        return TextRule;

    if (AdBlockRuleNullImpl::isNullFilter(filter))
        return NullRule;

    return FallbackRule;
}
