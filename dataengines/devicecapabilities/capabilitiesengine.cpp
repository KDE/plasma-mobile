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

CapabilitiesEngine::CapabilitiesEngine(QObject* parent, const QVariantList& args)
    : Plasma::DataEngine(parent)
{
    Q_UNUSED(args);
    m_sources << "Input" << "PowerManagement" << "Screen";
}

void CapabilitiesEngine::init()
{
}

CapabilitiesEngine::~CapabilitiesEngine()
{
}

QStringList CapabilitiesEngine::sources() const
{
    return m_sources;
}

bool CapabilitiesEngine::sourceRequestEvent(const QString &name)
{
    if (name == "Input") {
        kDebug() << "##############################################################";
        kDebug() << "Device Capabilities";
        kDebug() << "##############################################################";
        KSharedConfigPtr ptr = KSharedConfig::openConfig("device-capabilitiesrc");
        KConfigGroup config = KConfigGroup(ptr, "Input");
        bool hasHomeButton = config.readEntry("hasHomeButton", false);
        setData(name, "hasHomeButton", hasHomeButton);
        bool hasBackButton = config.readEntry("hasBackButton", false);
        setData(name, "hasBackButton", hasBackButton);
        bool hasMenuButton = config.readEntry("hasMenuButton", false);
        setData(name, "hasMenuButton", hasMenuButton);
        bool hasSearchButton = config.readEntry("hasSearchButton", false);
        setData(name, "hasSearchButton", hasSearchButton);
        bool hasPowerButton = config.readEntry("hasPowerButton", true);
        setData(name, "hasPowerButton", hasPowerButton);

    } else if (name == "PowerManagement") {
        setData(name, Plasma::DataEngine::Data());
    } else if (name == "Screen") {
        setData(name, Plasma::DataEngine::Data());
    } else {
        return false;
    }

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
