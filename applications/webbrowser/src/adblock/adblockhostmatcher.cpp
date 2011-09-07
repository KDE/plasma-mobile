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
#include "adblockhostmatcher.h"

bool AdBlockHostMatcher::tryAddFilter(const QString &filter)
{
    if (filter.startsWith(QL1S("||")))
    {

        QString domain = filter.mid(2);

        if (!domain.endsWith(QL1C('^')))
            return false;

        if (domain.contains(QL1C('$')))
            return false;

        domain = domain.left(domain.size() - 1);

        if (domain.contains(QL1C('/')) || domain.contains(QL1C('*')) || domain.contains(QL1C('^')))
            return false;

        domain = domain.toLower();
        m_hostList.insert(domain);
        m_hostList.insert(QL1S("www.") + domain);
        return true;
    }
    return false;
}
