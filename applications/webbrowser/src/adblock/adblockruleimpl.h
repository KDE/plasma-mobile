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

#ifndef ADBLOCKRULEIMPL_H
#define ADBLOCKRULEIMPL_H

class QString;
class QNetworkRequest;

class AdBlockRuleImpl
{
public:
    AdBlockRuleImpl(const QString &) {}
    virtual ~AdBlockRuleImpl() {}
    virtual bool match(const QNetworkRequest &request, const QString &encodedUrl, const QString &encodedUrlLowerCase) const = 0;

    // This are added just for debugging purposes
    virtual QString ruleString() const = 0;
    virtual QString ruleType() const = 0;
};

#endif // ADBLOCKRULEIMPL_H
