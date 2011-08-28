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
};


History::History(QObject *parent)
    : QObject(parent)
{
    d = new HistoryPrivate;
    KSharedConfigPtr ptr = KSharedConfig::openConfig("active-webbrowserrc");
    d->config = KConfigGroup(ptr, "history");

    loadHistory();
    d->icon = KIcon("view-history").pixmap(48, 48).toImage();
    d->icon = QImage("/home/sebas/Documents/wallpaper.png");
    kDebug() << "ionsize" << d->icon.size();
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

    kDebug() << "populating history...";
    QStringList h = d->config.readEntry("history", QStringList("empty"));
    foreach (const QString &hitem, h) {
        addPage(hitem, "history item");
    }
    /*
    addPage("http://tagesschau.de", "Tagesschau");
    addPage("http://planetkde.org", "Planet KDE");
    addPage("http://vizZzion.org/stuff/cookie.php", "Cookie Test");
    addPage("http://google.com", "G--gle");
    */
}

void History::addPage(const QString &url, const QString &title)
{
    CompletionItem* item = new CompletionItem(title, url, d->icon, this);
    item->setIconName("view-history");
    d->items.append(item);
    emit dataChanged();
}

void History::saveHistory()
{
    QStringList l;
    l.append("http://lwn.net");
    l.append("http://vizZzion.org/stuff/cookie.php");
    l.append("http://volkskrant.nl");
    l.append("http://heise.de");
    d->config.writeEntry("history", l);
    d->config.sync();
}

#include "history.moc"
