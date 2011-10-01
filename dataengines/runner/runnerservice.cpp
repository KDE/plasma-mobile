/*
 * Copyright 2011 Marco Martin <mart@kde.org>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Library General Public License version 2 as
 * published by the Free Software Foundation
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Library General Public License for more details
 *
 * You should have received a copy of the GNU Library General Public
 * License along with this program; if not, write to the
 * Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#include "runnerservice.h"

// own
#include "runnerjob.h"

RunnerService::RunnerService(RunnerSource *source) :
    Plasma::Service(source),
    m_source(source)
{
    setName("org.kde.runner");
}

RunnerService::~RunnerService()
{
}

Plasma::ServiceJob *RunnerService::createJob(const QString &operation, QMap<QString, QVariant> &parameters)
{
    return new RunnerJob(m_source, operation, parameters, this);
}

#include "runnerservice.moc"
