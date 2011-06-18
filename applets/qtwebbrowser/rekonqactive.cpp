/***************************************************************************
 *                                                                         *
 *   Copyright 2011 Sebastian Kügler <sebas@kde.org>                       *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA .        *
 ***************************************************************************/

#include <KIcon>
#include "rekonqactive.h"

RekonqActive::RekonqActive(const QString &url)
    : KMainWindow()
{
    setAcceptDrops(true);
    m_widget = new View(url, this);
    restoreWindowSize(config("Window"));
    setCentralWidget(m_widget);
}

RekonqActive::~RekonqActive()
{
    saveWindowSize(config("Window"));
}

KConfigGroup RekonqActive::config(const QString &group)
{
    return KConfigGroup(KSharedConfig::openConfig("rekonqactiverc"), group);
}

QString RekonqActive::name()
{
    return "Rekonq Active";
    //return m_widget->options()->name;
}

QIcon RekonqActive::icon()
{
    return KIcon("internet-web-browser");
}

#include "rekonqactive.moc"
