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

#include "completionitem.h"
#include "bookmark.h"

#include <kdebug.h>
#include <Nepomuk/Variant>

class CompletionItemPrivate {
public:
    QString name;
    QString url;
    QString iconName;
    QImage preview;
    QUrl resourceUri;
};


CompletionItem::CompletionItem(const QString &n, const QString &u, const QImage &i, QObject *parent)
    : QObject(parent)
{
    d = new CompletionItemPrivate;
    d->name = n;
    d->url = u;
    d->preview = i;
}

CompletionItem::CompletionItem(QObject *parent)
    : QObject(parent)
{
    d = new CompletionItemPrivate;
    d->name = QString();
    d->url = QString();
    d->preview = QImage();
}

void CompletionItem::setResource(Nepomuk::Resource resource)
{
    //d->url = resource.
    //kDebug() << "!!!!! res props: " << resource.properties().keys();
    //kDebug() << "SET RESOURCE" << resource.resourceUri();
    d->name = resource.genericDescription();
    //d->url = resource.property(QUrl("http://www.semanticdesktop.org/ontologies/2007/01/19/nie#url")).toString();
    //d->url = resource.property(Nepomuk::Bookmark::bookmarksUri()).toString();
    d->url = resource.description();
    d->name.remove("http://");
    //kDebug() << "Bookmark: " << d->name << d->url;
    d->iconName = "bookmarks";
    //d->url = resource.property(resour).toString();
    d->resourceUri = resource.resourceUri();
}

QUrl CompletionItem::resourceUri()
{
    return d->resourceUri;
}

CompletionItem::~CompletionItem()
{
    delete d;
}

QString CompletionItem::name()
{
    return d->name;
}

QString CompletionItem::url()
{
    return d->url;
}

QString CompletionItem::iconName()
{
    return d->iconName;
}

QImage CompletionItem::preview()
{
    return d->preview;
}

void CompletionItem::setName(const QString &name)
{
    d->name = name;
}

void CompletionItem::setIconName(const QString &iconName)
{
    d->iconName = iconName;
}

void CompletionItem::setUrl(const QString &url)
{
    d->url = url;
}

void CompletionItem::setPreview(const QImage &preview)
{
    d->preview = preview;
}

#include "completionitem.moc"
