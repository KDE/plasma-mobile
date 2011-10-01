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

#ifndef RUNNERSOURCE_H
#define RUNNERSOURCE_H

// plasma
#include <Plasma/DataContainer>
#include <Plasma/QueryMatch>

namespace Plasma {
    class RunnerManager;
}

/**
 * Runner results Source
 */
class RunnerSource : public Plasma::DataContainer
{
    Q_OBJECT

public:
    RunnerSource(const QString &name, QObject *parent = 0);
    ~RunnerSource();

    Plasma::RunnerManager *runnerManager() const;

protected:
    Plasma::Service *createService();

protected Q_SLOTS:
    void matchesChanged(const QList< Plasma::QueryMatch > &m);

private:
    QStringList m_runners;
    QString m_query;
    Plasma::RunnerManager *m_runnerManager;
};

#endif // RUNNERSOURCE_H
