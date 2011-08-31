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
 * GNU General Public License for more details
 *
 * You should have received a copy of the GNU Library General Public
 * License along with this program; if not, write to the
 * Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#include "runnerjob.h"

#include <KRun>

#include <Plasma/RunnerManager>

RunnerJob::RunnerJob(RunnerSource *source, const QString &operation, QMap<QString, QVariant> &parameters, QObject *parent)
    : ServiceJob(source->objectName(), operation, parameters, parent),
      m_source(source)
{
}

RunnerJob::~RunnerJob()
{
}

void RunnerJob::start()
{
    const QString operation = operationName();

    if (operation == "run") {
        const QString resultId(parameters().value("id").toString());

        m_source->runnerManager()->run(resultId);
        setResult(true);
        return;
    }

    setResult(false);
}

#include "runnerjob.moc"
