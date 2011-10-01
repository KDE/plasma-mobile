/*
 * Copyright 2011 Marco Martin <mart@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License version 2 as
 *   published by the Free Software Foundation
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU Library General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#include "runnerengine.h"
#include "runnersource.h"
#include "runnerservice.h"



RunnerEngine::RunnerEngine(QObject *parent, const QVariantList &args) :
    Plasma::DataEngine(parent, args)
{
    Q_UNUSED(args);
}

RunnerEngine::~RunnerEngine()
{
}

bool RunnerEngine::sourceRequestEvent(const QString &name)
{
    if (containerForSource(name)) {
        return true;
    }

    RunnerSource *appSource = new RunnerSource(name, this);
    addSource(appSource);
    return true;
}

Plasma::Service *RunnerEngine::serviceForSource(const QString &name)
{
    RunnerSource *source = dynamic_cast<RunnerSource*>(containerForSource(name));
    // if source does not exist, return null service
    if (!source) {
        return Plasma::DataEngine::serviceForSource(name);
    }

    // if source is a group of apps, return real service
    Plasma::Service *service = new RunnerService(source);
    service->setParent(this);
    return service;
}

K_EXPORT_PLASMA_DATAENGINE(runner, RunnerEngine)

#include "runnerengine.moc"
