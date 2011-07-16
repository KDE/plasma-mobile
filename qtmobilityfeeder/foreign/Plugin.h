/*
 *   Copyright (C) 2011 Ivan Cukic <ivan.cukic(at)kde.org>
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

#ifndef EVENT_BACKEND_H_
#define EVENT_BACKEND_H_

#include <kdemacros.h>
#include <KPluginFactory>
#include <KPluginLoader>

#include "Event.h"
#include "SharedInfo.h"

#define KAMD_EXPORT_PLUGIN(ClassName, AboutData)                       \
    K_PLUGIN_FACTORY(ClassName##Factory, registerPlugin<ClassName>();) \
    K_EXPORT_PLUGIN(ClassName##Factory("AboutData"))


/**
 *
 */
class KDE_EXPORT Plugin: public QObject {
    Q_OBJECT

public:
    Plugin(QObject * parent);
    virtual ~Plugin();

    virtual void addEvents(const EventList & events);
    virtual void setResourceMimeType(const QString & uri, const QString & mimetype);

    virtual void setSharedInfo(SharedInfo * sharedInfo);
    SharedInfo * sharedInfo() const;

private:
    class Private;
    Private * const d;
};

#endif // EVENT_BACKEND_H_

