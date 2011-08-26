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

#include "runnersource.h"

#include <QIcon>
#include <QMimeData>

#include <KDebug>
#include <KServiceTypeTrader>
#include <KSycoca>

#include <Plasma/RunnerManager>

RunnerSource::RunnerSource(const QString &name, QObject *parent)
    : Plasma::DataContainer(parent)
{
    setObjectName(name);

    QStringList names = name.split(':');
    m_query = names.first().trimmed();
    if (names.length() == 2) {
        m_runners = names.last().split('|');
    }

    //one for each source is a waste, but we can need different queries ran at once with different runners
    m_runnerManager = new Plasma::RunnerManager(this);

    QString runner;
    if (m_runners.count() == 1) {
        runner = m_runners.first();
    } else if (m_runners.count() > 1) {
        m_runnerManager->setAllowedRunners(m_runners);
    }

    connect(m_runnerManager,
            SIGNAL(matchesChanged (const QList< Plasma::QueryMatch > & )),
            this,
            SLOT(matchesChanged (const QList< Plasma::QueryMatch > & )));

    m_runnerManager->reset();

    m_runnerManager->launchQuery(m_query, runner);
}

RunnerSource::~RunnerSource()
{
}


void RunnerSource::matchesChanged(const QList< Plasma::QueryMatch > &m)
{
    QList< Plasma::QueryMatch > matches = m;

    qSort(matches.begin(), matches.end());

    removeAllData();

    while (matches.size()) {
        Plasma::QueryMatch match = matches.takeLast();

        QString resourceUri;
        QString mimeType;
        QMimeData *mimeData = m_runnerManager->mimeDataForMatch(match.id());
        if (mimeData) {
            if (!mimeData->formats().isEmpty()) {
                mimeType = mimeData->formats().first();
            }
            if (!mimeData->urls().isEmpty()) {
                resourceUri = mimeData->urls().first().toString();
            }
        }

        Plasma::DataEngine::Data data;

        data["icon"] = match.icon();
        data["text"] = match.text();
        data["subText"] = match.subtext();
        data["id"] = match.id();
        data["resourceUri"] = resourceUri;
        data["mimeType"] = mimeType;
        setData(match.id(), data);
    }

    checkForUpdate();
}

Plasma::RunnerManager *RunnerSource::runnerManager() const
{
    return m_runnerManager;
}

#include "runnersource.moc"
