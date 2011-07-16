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

#ifndef SHARED_INFO_H_
#define SHARED_INFO_H_

#include <KUrl>
#include <QSet>
#include <QString>
#include <QHash>

#include <KConfigGroup>
#include <KConfig>

#include "Event.h"

/**
 *
 */
class SharedInfo {
public:
    virtual ~SharedInfo();

    struct WindowData {
        QSet < KUrl > resources;
        QString application;
    };

    struct ResourceData {
        Event::Reason reason;
        QSet < QString > activities;
        QString mimetype;
    };

    QHash < WId, WindowData > const & windows() const;
    QHash < KUrl, ResourceData > const & resources() const;

    QString currentActivity() const;

    KConfigGroup pluginConfig(const QString & pluginName) const;

private:
    static SharedInfo * self();

    void setCurrentActivity(const QString & activity);

    QHash < WId, WindowData > m_windows;
    QHash < KUrl, ResourceData > m_resources;
    QString m_currentActivity;
    KConfig m_config;

    static SharedInfo * s_instance;
    SharedInfo();

    friend class ActivityManager;
    friend class ActivityManagerPrivate;
    friend class EventProcessor;
};

#endif // SHARED_INFO_H_
