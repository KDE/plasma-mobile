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

#include <kdebug.h>
#include <Nepomuk/Variant>

class CompletionItemPrivate {
public:
    QString name;
    QString url;
    QImage image;
};


CompletionItem::CompletionItem(const QString &n, const QString &u, const QImage &i, QObject *parent)
    : QObject(parent)
{
    d = new CompletionItemPrivate;
    d->name = n;
    d->url = u;
    d->image = i;
}

CompletionItem::CompletionItem(QObject *parent)
    : QObject(parent)
{
    d = new CompletionItemPrivate;
    d->name = QString();
    d->url = QString();
    d->image = QImage();
}

void CompletionItem::setResource(Nepomuk::Resource resource)
{
    //d->url = resource.
    //kDebug() << "!!!!! res props: " << resource.properties().keys();
    kDebug() << "SET RESOURCE" << resource.resourceUri();
    d->name = resource.genericDescription();
    d->url = resource.property(QUrl("http://www.semanticdesktop.org/ontologies/2007/01/19/nie#url")).toString();
    //d->url = resource.property(resour).toString();
    
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

QImage CompletionItem::image()
{
    return d->image;
}

void CompletionItem::setName(const QString &name)
{
    d->name = name;
}

void CompletionItem::setUrl(const QString &url)
{
    d->url = url;
}

void CompletionItem::setImage(const QImage &image)
{
    d->image = image;
}

#include "completionitem.moc"
