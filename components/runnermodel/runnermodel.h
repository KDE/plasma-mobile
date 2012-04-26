/*
    Copyright 2011 Aaron Seigo <aseigo@kde.org>

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Library General Public
    License as published by the Free Software Foundation; either
    version 2 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Library General Public License for more details.

    You should have received a copy of the GNU Library General Public License
    along with this library; see the file COPYING.LIB.  If not, write to
    the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
    Boston, MA 02110-1301, USA.
*/

#ifndef RUNNERMODEL_H
#define RUNNERMODEL_H

#include <QAbstractListModel>
#include <QStringList>

namespace Plasma
{
    class RunnerManager;
    class QueryMatch;
} // namespace Plasma

class QTimer;

/**
 * This model provides bindings to use KRunner from QML
 *
 * @author Aaron Seigo <aseigo@kde.org>
 */
class RunnerModel : public QAbstractListModel
{
    Q_OBJECT

    /**
     * @property string set the KRunner query
     */
    Q_PROPERTY(QString query WRITE scheduleQuery READ currentQuery NOTIFY queryChanged)

    /**
     * @property Array The list of all allowed runner plugins that will be executed
     */
    Q_PROPERTY(QStringList runners WRITE setRunners READ runners NOTIFY runnersChanged)

    /**
     * @property int The number of rows of the model
     */
    Q_PROPERTY(int count READ count NOTIFY countChanged)

public:
    /**
     * @enum Roles of the model, they will be accessible from delegates
     */
    enum Roles {
        Type = Qt::UserRole + 1,
        Relevance,
        Data,
        Id,
        SubText,
        Enabled,
        RunnerId,
        RunnerName,
        Actions
    };

    RunnerModel(QObject *parent = 0);

    QString currentQuery() const;

    QStringList runners() const;
    void setRunners(const QStringList &allowedRunners);

    Q_SCRIPTABLE void run(int row);

    int rowCount(const QModelIndex&) const;
    int count() const;
    QVariant data(const QModelIndex&, int) const;

public Q_SLOTS:
    void scheduleQuery(const QString &query);

Q_SIGNALS:
    void queryChanged();
    void countChanged();
    void runnersChanged();

private Q_SLOTS:
    void startQuery();

private:
    void createManager();

private Q_SLOTS:
    void matchesChanged(const QList<Plasma::QueryMatch> &matches);

private:
    Plasma::RunnerManager *m_manager;
    QList<Plasma::QueryMatch> m_matches;
    QStringList m_pendingRunnersList;
    QString m_pendingQuery;
    QTimer *m_startQueryTimer;
};

#endif
