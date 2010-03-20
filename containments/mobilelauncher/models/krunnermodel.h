/*
    Copyright 2009 Ivan Cukic <ivan.cukic+kde@gmail.com>
    Copyright 2010 Marco Martin <notmart@gmail.com>

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

#ifndef KRUNNERMODEL_H
#define KRUNNERMODEL_H

#include <QStandardItemModel>

#include <KUrl>

#include <Plasma/QueryMatch>

#include "standarditemfactory.h"

namespace Plasma
{
    class RunnerManager;
}

namespace KRunnerItemHandler {
    bool openUrl(const KUrl& url);
}

class KRunnerModel : public QStandardItemModel
{
    Q_OBJECT

public:
    KRunnerModel(QObject *parent);
    virtual ~KRunnerModel();

    virtual Qt::ItemFlags flags(const QModelIndex &index) const;
    virtual QMimeData *mimeData(const QModelIndexList &indexes) const;

    static Plasma::RunnerManager *runnerManager();

private:
    void timerEvent(QTimerEvent * event);

public Q_SLOTS:
    void setQuery(const QString& query, const QString& runner = QString());

private Q_SLOTS:
    void matchesChanged(const QList< Plasma::QueryMatch > & matches);

Q_SIGNALS:
    void resultsAvailable();

private:
    class Private;
    Private * const d;
};

#endif // KRUNNERMODEL_H

