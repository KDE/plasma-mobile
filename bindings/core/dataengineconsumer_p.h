/*
 *   Copyright 2005 by Aaron Seigo <aseigo@kde.org>
 *   Copyright 2007 by Riccardo Iaconelli <riccardo@kde.org>
 *   Copyright 2008 by Ménard Alexis <darktears31@gmail.com>
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

#ifndef PLASMA_DATAENGINECONSUMER_H
#define PLASMA_DATAENGINECONSUMER_H

#include <QtCore/QSet>

#include <kdebug.h>

#include "plasma/dataenginemanager.h"
#include <plasma/servicejob.h>

namespace Plasma
{

class DataEngineConsumer;
class RemoteDataEngine;

class ServiceMonitor : public QObject
{
    Q_OBJECT
public:
    ServiceMonitor(DataEngineConsumer *consumer);
    ~ServiceMonitor();

public Q_SLOTS:
    void slotJobFinished(Plasma::ServiceJob *job);
    void slotServiceReady(Plasma::Service *service);

private:
    DataEngineConsumer *m_consumer;
};

class DataEngineConsumer
{
public:
    DataEngineConsumer();
    ~DataEngineConsumer();
    DataEngine *dataEngine(const QString &name);
    DataEngine *remoteDataEngine(const KUrl &location, const QString &name);

private:
    QSet<QString> m_loadedEngines;
    QMap<QPair<QString, QString>, RemoteDataEngine*> m_remoteEngines;
    QMap<Service*, QString> m_engineNameForService;
    ServiceMonitor *m_monitor;

    friend class ServiceMonitor;
};

} // namespace Plasma

#endif


