/***************************************************************************
 *                                                                         *
 *   Copyright 2011 Sebastian Kügler <sebas@kde.org>                       *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA .        *
 ***************************************************************************/

#include "history.h"
#include "completionitem.h"
#include <QTimer>
#include <KIcon>
#include "kdebug.h"

#include <KConfigGroup>
#include <KDirWatch>
#include <KSharedConfig>
#include <KStandardDirs>

class HistoryPrivate {

public:
    QList<QObject*> items;
    QImage icon;
    KConfigGroup config;
    KDirWatch* dirWatch;
    QTimer saveTimer;
    QString separator;
    CompletionItem* currentPage;
    QTimer addHistoryTimer;
};


History::History(QObject *parent)
    : QObject(parent)
{
    d = new HistoryPrivate;
    d->dirWatch = new KDirWatch(this);

    QString configPath = KStandardDirs::locateLocal("config", "active-webbrowserrc");
    //kDebug() << "XXXXX configPath is " << configPath;
    d->dirWatch->addFile(configPath);
    d->separator = "|X|";
    d->currentPage = 0;
    // wait 30 sec before saving to history,
    // transient pages aren't interesting enough
    d->addHistoryTimer.setInterval(30000);
    connect(&d->addHistoryTimer, SIGNAL(timeout()), SLOT(recordHistory()));
    connect(d->dirWatch, SIGNAL(dirty(const QString&)), SLOT(loadHistory()));
    connect(d->dirWatch, SIGNAL(created(const QString&)), SLOT(loadHistory()));

}

History::~History()
{
    delete d;
}

QList<QObject*> History::items()
{
    return d->items;
}

void History::loadHistory()
{
    KSharedConfigPtr ptr = KSharedConfig::openConfig("active-webbrowserrc");
    KConfigGroup config = KConfigGroup(ptr, "history");
    d->items.clear();
    QStringList h = config.readEntry("history", QStringList());
    foreach (const QString &hitem, h) {
        QStringList hs = hitem.split(d->separator);
        //kDebug() << "XXX history: " << hs;
        QString url = hs.at(0);
        QString title;
        if (url.isEmpty()) {
            continue;
        }
        if (hs.count() > 1) {
            title = hs.at(1);
        }
        CompletionItem* item = new CompletionItem(title, url, d->icon, this);
        item->setIconName("view-history");
        d->items.append(item);
    }
    emit dataChanged();
    //kDebug() << "XXX (Re)loaded history..." << d->items.count();
}

void History::addPage(const QString &url, const QString &title)
{
    kDebug() << "XXX Adding page" << title << url;
    if (url.isEmpty() && title.isEmpty()) {
        return;
    }
    // Remove entry from earlier in the history: less clutter
    foreach (QObject* i, d->items) {
        CompletionItem* ci = qobject_cast<CompletionItem*>(i);
        if (ci->url() == url) {
            kDebug() << "XXXXX Removing " << ci->name() << " ... " << ci->url();
            d->items.removeAll(i);
        }
    }

    CompletionItem* item = new CompletionItem(title, url, d->icon, this);
    item->setIconName("view-history");
    d->items.append(item);
    while (d->items.count() > 256) {
        d->items.takeLast();
    }
}

void History::visitPage(const QString &url, const QString &title)
{
    //kDebug() << "XXXX Visiting page" << title << url;
    d->currentPage = new CompletionItem(title, url, d->icon, this);
    d->currentPage->setIconName("view-history");
    //kDebug() << "XXX starting timer";
    d->addHistoryTimer.start();
}

void History::recordHistory()
{
    //kDebug() << "XXX Recording history!";
    d->addHistoryTimer.stop();
    addPage(d->currentPage->url(), d->currentPage->name());
    emit dataChanged();
    saveHistory();
}

void History::saveHistory()
{
    QStringList l;
    foreach(QObject* it, d->items) {
        CompletionItem* ci = qobject_cast<CompletionItem*>(it);
        if (ci) {
            l.append(ci->url() + d->separator + ci->name());
        }
    }
    KSharedConfigPtr ptr = KSharedConfig::openConfig("active-webbrowserrc");
    KConfigGroup config = KConfigGroup(ptr, "history");
    config.writeEntry("history", l);
    config.sync();
    //kDebug() << "XXX History saved to disk";
}

#include "history.moc"
