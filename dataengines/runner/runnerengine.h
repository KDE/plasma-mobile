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
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#ifndef RUNNERENGINE_H
#define RUNNERENGINE_H

// plasma
#include <Plasma/DataEngine>
#include <Plasma/Service>

#include <KService>
#include <KServiceGroup>

/**
 * Data Engine that returns results from KRunner queries
 */
class RunnerEngine : public Plasma::DataEngine
{
    Q_OBJECT

public:
    RunnerEngine(QObject *parent, const QVariantList &args);
    ~RunnerEngine();

    bool sourceRequestEvent(const QString &name);
    Plasma::Service *serviceForSource(const QString &name);
};

#endif // RUNNERENGINE_H
