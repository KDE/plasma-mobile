/*
 *   Copyright 2009 Marco Martin <notmart@gmail.com>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License as
 *   published by the Free Software Foundation; either version 2,
 *   or (at your option) any later version.
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

#ifndef BUSYAPP_H
#define BUSYAPP_H

#include <KUniqueApplication>
#include <KStartupInfo>
#include <KStartupInfoData>

#include <plasma/plasma.h>

#ifdef Q_WS_X11
#include <X11/Xlib.h>
#include <fixx11h.h>
#endif

class BusyWidget;
class KStartupInfo;

class BusyApp : public KUniqueApplication
{
    Q_OBJECT
public:
    ~BusyApp();

    int newInstance();

    static BusyApp* self();

protected Q_SLOTS:
    void gotNewStartup(const KStartupInfoId& id, const KStartupInfoData& data);
    void gotStartupChange(const KStartupInfoId& id, const KStartupInfoData& data);
    void killStartup(const KStartupInfoId& id);
    void windowAdded(WId id);

private:
    BusyApp();

private:
    KStartupInfo *m_startupInfo;
    QWeakPointer<BusyWidget> m_busyWidget;
};

#endif // multiple inclusion guard

