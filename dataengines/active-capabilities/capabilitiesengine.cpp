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
#include "powermanagementservice.h"

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
}

void CapabilitiesEngine::init()
{
    emptySources();
}

void CapabilitiesEngine::emptySources()
{
    setData("Input", Plasma::DataEngine::Data());
    setData("PowerManagement", Plasma::DataEngine::Data());
    setData("Screen", Plasma::DataEngine::Data());
    scheduleSourcesUpdated();
}


CapabilitiesEngine::~CapabilitiesEngine()
{
    delete d;
}

QStringList CapabilitiesEngine::sources() const
{
    return QStringList() << "Input" << "PowerManagement" << "Screen";
}

bool CapabilitiesEngine::sourceRequestEvent(const QString &name)
{
    setData(name, Plasma::DataEngine::Data());
    // more
    return true;
}

Plasma::Service* CapabilitiesEngine::serviceForSource(const QString &source)
{
    if (source == "PowerManagement") {
        PowerManagementService *service = new PowerManagementService(source);
        service->setParent(this);
        return service;
    } else if (source == "Screen") {
        kWarning() << "FIXME: Service \"Screen\" not yet implemented";
    } else if (source == "Input") {
        kWarning() << "FIXME: Service \"Input\" not yet implemented";
    } else {
        kWarning() << "No service for " << source << "found, " <<
                      "should be \"PowerManagement\", \"Input\" or \"Screen\".";
    }
    return 0;
}

#include "capabilitiesengine.moc"
