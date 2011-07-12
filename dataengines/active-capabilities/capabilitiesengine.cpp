/*
    Copyright 2011 Sebastian Kügler <sebas@kde.org>

    This library is free software; you can redistribute it and/or modify it
    under the terms of the GNU Library General Public License as published by
    the Free Software Foundation; either version 2 of the License, or (at your
    option) any later version.

    This library is distributed in the hope that it will be useful, but WITHOUT
    ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
    FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Library General Public
    License for more details.

    You should have received a copy of the GNU Library General Public License
    along with this library; see the file COPYING.LIB.  If not, write to the
    Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
    02110-1301, USA.
*/


#include "capabilitiesengine.h"

class CapabilitiesEnginePrivate
{
public:
    //int i;
};


CapabilitiesEngine::CapabilitiesEngine(QObject* parent, const QVariantList& args)
    : Plasma::DataEngine(parent)
{
    Q_UNUSED(args);
    d = new CapabilitiesEnginePrivate;
    setMaxSourceCount(64); // Guard against loading too many connections
    init();
}

void CapabilitiesEngine::init()
{
    setData("Input", Plasma::DataEngine::Data());
    setData("PowerManagement", Plasma::DataEngine::Data());
    setData("Screen", Plasma::DataEngine::Data());   
}

CapabilitiesEngine::~CapabilitiesEngine()
{
    delete d;
}

QStringList CapabilitiesEngine::sources() const
{
    return QStringList();
}

bool CapabilitiesEngine::sourceRequestEvent(const QString &name)
{

    setData(name, Plasma::DataEngine::Data());
    // more
    return true;
}


#include "capabilitiesengine.moc"
