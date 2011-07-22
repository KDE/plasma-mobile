/***************************************************************************
 *   Copyright 2011 by Davide Bettio <davide.bettio@kdemail.net>           *
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

#include "mobileprofileengine.h"
#include "mobileprofilesource.h"

MobileProfileEngine::MobileProfileEngine(QObject* parent, const QVariantList& args)
    : Plasma::DataEngine(parent, args)
{
}

MobileProfileEngine::~MobileProfileEngine()
{
}


bool MobileProfileEngine::sourceRequestEvent(const QString &name)
{
    if (name == "default") {
        updateSourceEvent(name);
        return true;
    }

    return false;
}


bool MobileProfileEngine::updateSourceEvent(const QString &name)
{
    MobileProfileSource *source = dynamic_cast<MobileProfileSource *>(containerForSource(name));

    if (!source) {
        source = new MobileProfileSource(this);
        source->setObjectName(name);

        addSource(source);
    }

    source->update();
    return false;
}

#include "mobileprofileengine.moc"
