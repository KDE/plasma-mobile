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

#include <QAbstractItemModel>

namespace Plasma
{
    class RunnerManager;
    class QueryMatch;
} // namespace Plasma

class RunnerModel : public QAbstractItemModel
{
    Q_OBJECT
    Q_PROPERTY(QString query WRITE startQuery READ currentQuery NOTIFY queryChanged)
    Q_PROPERTY(QStringList runners WRITE setRunners READ runners)
    Q_PROPERTY(int count READ count NOTIFY countChanged)

public:
    enum Roles {
        Type = Qt::UserRole + 1,
        Relevance,
        Data,
        Id,
        SubText,
        Enabled
    };
    RunnerModel(QObject *parent);

    QString currentQuery() const;

    QStringList runners() const;
    void setRunners(const QStringList &allowedRunners);

    Q_SCRIPTABLE void run(int row);

    QModelIndex index(int, int, const QModelIndex&) const;
    QModelIndex parent(const QModelIndex&) const;
    int rowCount(const QModelIndex&) const;
    int count() const;
    int columnCount(const QModelIndex&) const;
    QVariant data(const QModelIndex&, int) const;

public Q_SLOTS:
    void startQuery(const QString &query);

Q_SIGNALS:
    void queryChanged();
    void countChanged();

private:
    void createManager();

private Q_SLOTS:
    void matchesChanged(const QList<Plasma::QueryMatch> &matches);

private:
    Plasma::RunnerManager *m_manager;
    QList<Plasma::QueryMatch> m_matches;
};

#endif
