/*
 *   Copyright (C) 2010 Ivan Cukic <ivan.cukic(at)kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License version 2,
 *   or (at your option) any later version, as published by the Free
 *   Software Foundation
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#include "SharedInfo.h"

#include <KDebug>

SharedInfo * SharedInfo::s_instance = NULL;

SharedInfo * SharedInfo::self()
{
    if (!s_instance) {
        s_instance = new SharedInfo();

        kDebug() << "SHARED INFO" << (void*) s_instance;
    }

    return s_instance;
}

SharedInfo::SharedInfo()
    : m_config("activitymanager-pluginsrc")
{
}

SharedInfo::~SharedInfo()
{
}

QHash < WId, SharedInfo::WindowData > const & SharedInfo::windows() const
{
    return m_windows;
}

QHash < KUrl, SharedInfo::ResourceData > const & SharedInfo::resources() const
{
    return m_resources;
}

QString SharedInfo::currentActivity() const
{
    return m_currentActivity;
}

void SharedInfo::setCurrentActivity(const QString & activity)
{
    m_currentActivity = activity;
}

KConfigGroup SharedInfo::pluginConfig(const QString & pluginName) const
{
    return KConfigGroup(&m_config, pluginName);
}

