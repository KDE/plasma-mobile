/* ============================================================
*
* This file is a part of the rekonq project
*
* Copyright (C) 2011 by Andrea Diamantini <adjam7 at gmail dot com>
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


#ifndef ADBLOCKRULE_NULL_IMPL_H
#define ADBLOCKRULE_NULL_IMPL_H


// Local Includes
#include "adblockruleimpl.h"

// Qt Includes
#include <QString>


class AdBlockRuleNullImpl : public AdBlockRuleImpl
{

public:
    AdBlockRuleNullImpl(const QString &filter);
    bool match(const QNetworkRequest &, const QString &, const QString &) const;

    static bool isNullFilter(const QString &filter);

    QString ruleString() const;
    QString ruleType() const;
};

#endif // ADBLOCKRULE_NULL_IMPL_H
