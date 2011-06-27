/*
 *   Copyright 2010 Marco Martin <notmart@gmail.com>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2, or
 *   (at your option) any later version.
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

#include "busyapp.h"
#include "busywidget.h"

#include <KCrash>
#include <KLocale>

BusyApp* BusyApp::self()
{
    if (!kapp) {
        return new BusyApp();
    }

    return qobject_cast<BusyApp*>(kapp);
}

BusyApp::BusyApp()
    : KUniqueApplication()
{
    KGlobal::locale()->insertCatalog("mobilebusynotifier");
    KCrash::setFlags(KCrash::AutoRestart);
}

BusyApp::~BusyApp()
{
}

int  BusyApp::newInstance()
{
    return 0;
}

#include "busyapp.moc"
