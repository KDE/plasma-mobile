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
    d->addHistoryTimer.setSingleShot(true);
    // wait 30 sec before saving to history,
    // transient pages aren't interesting enough
    d->addHistoryTimer.setInterval(30000);
    connect(&d->addHistoryTimer, SIGNAL(timeout()), SLOT(recordHistory()));

    d->saveTimer.setSingleShot(true);
    d->saveTimer.setInterval(30000); // wait 30 sec before saving to history
    connect(&d->saveTimer, SIGNAL(timeout()), SLOT(saveHistory()));
    //saveHistory();

    //loadHistory();
    //d->icon = KIcon("view-history").pixmap(48, 48).toImage();
    //d->icon = QImage("/home/sebas/Documents/wallpaper.png");
    //kDebug() << "ionsize" << d->icon.size();
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

    kDebug() << "populating history...";
    QStringList h = d->config.readEntry("history", QStringList("empty"));
    foreach (const QString &hitem, h) {
        QStringList hs = hitem.split(d->separator);
        kDebug() << "history: " << hs;
        QString url = hs.at(0);
        QString title;
        if (hs.count() > 1) {
            title = hs.at(1);
        }
        addPage(url, title);
    }
}

void History::addPage(const QString &url, const QString &title)
{
    CompletionItem* item = new CompletionItem(title, url, d->icon, this);
    item->setIconName("view-history");
    d->items.append(item);
    emit dataChanged();
}

void History::visitPage(const QString &url, const QString &title)
{
    kDebug() << "Visiting page" << title << url;
    d->currentPage = new CompletionItem(title, url, d->icon, this);
    d->currentPage->setIconName("view-history");
    d->addHistoryTimer.start();
}

void History::recordHistory()
{
    // TODO: re-query for the title here, page wasn't loaded before ...
    kDebug() << "count:" << d->items.count();
    d->items.insert(0, d->currentPage);
    while (d->items.count() > 256) {
        d->items.takeLast();
    }
    emit dataChanged();
    kDebug() << "DDD HIstory recorded: items count:" << d->items.count();
    d->saveTimer.start();
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
    kDebug() << "Saving history:" << l.join("\n");
    /*
    l.append("http://lwn.net" + d->separator + "Linux Weekly News");
    l.append("http://vizZzion.org/stuff/cookie.php" + d->separator + "Cookie Test");
    l.append("http://volkskrant.nl" + d->separator + "Volkskrant");
    l.append("http://heise.de" + d->separator + "Heise");
    l.append("http://tweakers.net");
    foreach (
    */
    d->config.writeEntry("history", l);
    d->config.sync();
}

#include "history.moc"
