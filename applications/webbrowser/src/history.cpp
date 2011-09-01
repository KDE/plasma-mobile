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
#include <KSharedConfig>

class HistoryPrivate {

public:
    QList<QObject*> items;
    QImage icon;
    KConfigGroup config;
    QTimer saveTimer;
    QString separator;
    CompletionItem* currentPage;
    QTimer addHistoryTimer;
};


History::History(QObject *parent)
    : QObject(parent)
{
    d = new HistoryPrivate;
    KSharedConfigPtr ptr = KSharedConfig::openConfig("active-webbrowserrc");
    d->config = KConfigGroup(ptr, "history");
    d->separator = "|X|";
    d->currentPage = 0;
    //d->addHistoryTimer.setSingleShot(true);
    // wait 30 sec before saving to history,
    // transient pages aren't interesting enough
    d->addHistoryTimer.setInterval(10000);
    connect(&d->addHistoryTimer, SIGNAL(timeout()), SLOT(recordHistory()));
}

History::~History()
{
    saveHistory();
    delete d;
}

QList<QObject*> History::items()
{
    return d->items;
}

void History::loadHistory()
{

    kDebug() << "XXX populating history...";

    QStringList h = d->config.readEntry("history", QStringList());
    foreach (const QString &hitem, h) {
        QStringList hs = hitem.split(d->separator);
        //kDebug() << "XXX history: " << hs;
        QString url = hs.at(0);
        QString title;
        if (hs.count() > 1) {
            title = hs.at(1);
        }
        CompletionItem* item = new CompletionItem(title, url, d->icon, this);
        item->setIconName("view-history");
        d->items.append(item);
    }
    emit dataChanged();
}

void History::addPage(const QString &url, const QString &title)
{
    if (d->currentPage && d->currentPage->url() == url && d->currentPage->name() == title) {
        kDebug() << "XXX nothing changed" << url << title;
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
    emit dataChanged();
}

void History::visitPage(const QString &url, const QString &title)
{
    kDebug() << "XXXX Visiting page" << title << url;
    d->currentPage = new CompletionItem(title, url, d->icon, this);
    d->currentPage->setIconName("view-history");
    kDebug() << "XXX starting timer";
    d->addHistoryTimer.start();
}

void History::recordHistory()
{
    kDebug() << "XXX Recording history!";
    d->addHistoryTimer.stop();
    d->items.insert(0, d->currentPage);
    while (d->items.count() > 256) {
        d->items.takeLast();
    }
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
    d->config.writeEntry("history", l);
    d->config.sync();
    kDebug() << "XXX History saved to disk";
}

#include "history.moc"
