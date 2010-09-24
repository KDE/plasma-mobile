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

#include <KAuthorized>

#include "appletauthorization.h"
#include <Plasma/AppletScript>
#include <Plasma/Applet>

AppletAuthorization::AppletAuthorization(Plasma::AppletScript *scriptEngine)
    : Authorization(),
      m_scriptEngine(scriptEngine)
{
}

bool AppletAuthorization::authorizeRequiredExtension(const QString &extension)
{
    bool ok = m_scriptEngine->applet()->hasAuthorization(extension);

    if (!ok) {
        m_scriptEngine->setFailedToLaunch(true,
                                          i18n("Authorization for required extension '%1' was denied.",
                                               extension));
    }

    return ok;
}

bool AppletAuthorization::authorizeOptionalExtension(const QString &extension)
{
    return m_scriptEngine->applet()->hasAuthorization(extension);
}

bool AppletAuthorization::authorizeExternalExtensions()
{
    return false;
}


