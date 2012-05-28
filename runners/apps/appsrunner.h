/*
 *   Copyright (C) 2012 Aaron Seigo <aseigo@kde.org>
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

#ifndef SERVICERUNNER_H
#define SERVICERUNNER_H


#include <KService>

#include <Plasma/AbstractRunner>

#include <QSet>

class ActiveAppsRunner : public Plasma::AbstractRunner
{
    Q_OBJECT

public:
    ActiveAppsRunner(QObject *parent, const QVariantList &args);
    ~ActiveAppsRunner();

    void match(Plasma::RunnerContext &context);
    void run(const Plasma::RunnerContext &context, const Plasma::QueryMatch &action);

protected slots:
    QMimeData *mimeDataForMatch(const Plasma::QueryMatch *match);

private:
    void setupMatch(const KService::Ptr &service, Plasma::QueryMatch &action);
    void serviceMatches(Plasma::RunnerContext &context);

private:
    QSet<QString> m_blackList;
};

K_EXPORT_PLASMA_RUNNER(activeapps, ActiveAppsRunner)

#endif

