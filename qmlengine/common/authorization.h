/*
 *   Copyright 2010 Aaron J. Seigo <aseigo@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License version 2 as
 *   published by the Free Software Foundation
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#ifndef AUTHORIZATION_H
#define AUTHORIZATION_H

#include <QString>

#include <KAuthorized>

class Authorization 
{
public:
    Authorization() {}
    virtual ~Authorization() {}

    virtual bool authorizeRequiredExtension(const QString &) { return true; }
    virtual bool authorizeOptionalExtension(const QString &) { return true; }
    virtual bool authorizeExternalExtensions() { return KAuthorized::authorize("plasma/external_script_extensions"); }
};

#endif

