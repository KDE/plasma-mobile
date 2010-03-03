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

// Own
#include "krunnermodel.h"

// Qt
#include <QBasicTimer>
#include <QDebug>
#include <QList>
#include <QMimeData>
#include <QString>
#include <QTimerEvent>

// KDE
#include <KService>
#include <KStandardDirs>
#include <Plasma/AbstractRunner>
#include <Plasma/RunnerManager>

#define DELAY_TIME 50


Plasma::RunnerManager * s_runnerManager = NULL;
Plasma::RunnerManager * runnerManager() {
    if (s_runnerManager == NULL) {
        s_runnerManager = new Plasma::RunnerManager();
    }
    return s_runnerManager;
}

KService::Ptr serviceForUrl(const KUrl & url)
{
    QString runner = url.host();
    QString id = url.path();

    if (id.startsWith(QLatin1String("/"))) {
        id = id.remove(0, 1);
    }

    if (runner != QLatin1String("services")) {
        return KService::Ptr(NULL);
    }

    // URL path example: services_kde4-kate.desktop
    // or: services_firefox.desktop
    id.remove("services_");

    return KService::serviceByStorageId(id);
}

QStandardItem *StandardItemFactory::createItem(const QIcon & icon, const QString & title,
        const QString & description, const QString & url)
{
    QStandardItem *appItem = new QStandardItem;

    appItem->setText(title);
    appItem->setIcon(icon);
    appItem->setData(description, Qt::UserRole + 1);
    appItem->setData(url, Qt::UserRole + 2);

    return appItem;
}



class ResultItem {
public:
    ResultItem()
    {
    }

    ResultItem(QIcon _icon, QString _name, QString _description, QVariant _data)
        : icon(_icon),
          name(_name),
          description(_description),
          data(_data)
    {
    }

    QIcon icon;
    QString name, description;
    QVariant data;
};

bool KRunnerItemHandler::openUrl(const KUrl& url)
{
    QString runner = url.host();
    QString id = url.path();
    if (id.startsWith(QLatin1String("/"))) {
        id = id.remove(0, 1);
    }

    runnerManager()->run(id);
    return true;
}

class KRunnerModel::Private {
public:
    Private()
    {
    }

    ~Private()
    {
    }

    QBasicTimer searchDelay;
    QString searchQuery;
};

KRunnerModel::KRunnerModel(QObject *parent)
        : QStandardItemModel(parent)
        , d(new Private())
{
    connect(runnerManager(),
            SIGNAL(matchesChanged (const QList< Plasma::QueryMatch > & )),
            this,
            SLOT(matchesChanged (const QList< Plasma::QueryMatch > & )));
}

KRunnerModel::~KRunnerModel()
{
    delete d;
}

void KRunnerModel::setQuery(const QString& query)
{
    runnerManager()->reset();
    clear();

    d->searchQuery = query.trimmed();

    if (d->searchQuery.isEmpty()) {
        return;
    }

    d->searchDelay.start(DELAY_TIME, this);
}

void KRunnerModel::timerEvent(QTimerEvent * event)
{
    QStandardItemModel::timerEvent(event);

    if (event->timerId() == d->searchDelay.timerId()) {
        d->searchDelay.stop();
        runnerManager()->launchQuery(d->searchQuery);
    };
}


void KRunnerModel::matchesChanged(const QList< Plasma::QueryMatch > & m)
{
    QList< Plasma::QueryMatch > matches = m;

    qSort(matches.begin(), matches.end());

    clear();

    while (matches.size()) {
        Plasma::QueryMatch match = matches.takeLast();

        appendRow(
            StandardItemFactory::createItem(
                match.icon(),
                match.text(),
                match.subtext(),
                QString("krunner://") + match.runner()->id() + "/" + match.id()
                )
            );
    }
}

Qt::ItemFlags KRunnerModel::flags(const QModelIndex &index) const
{
    Qt::ItemFlags flags = QStandardItemModel::flags(index);

    if (index.isValid()) {
        KUrl url = data(index, Qt::UserRole+2).toString();
        QString host = url.host();
        if (host != "services") {
            flags &= ~ ( Qt::ItemIsDragEnabled | Qt::ItemIsDropEnabled );
        }
    } else {
        flags = 0;
    }

    return flags;
}

QMimeData * KRunnerModel::mimeData(const QModelIndexList &indexes) const
{
    KUrl::List urls;

    foreach (const QModelIndex & index, indexes) {
        KUrl url = data(index, Qt::UserRole+2).toString();

        KService::Ptr service = serviceForUrl(url);

        if (service) {
            urls << KUrl(service->entryPath());
        }
    }

    QMimeData *mimeData = new QMimeData();

    if (!urls.isEmpty()) {
        urls.populateMimeData(mimeData);
    }

    return mimeData;

}

#include "krunnermodel.moc"
