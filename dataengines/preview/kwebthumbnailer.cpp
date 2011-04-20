/*
    Copyright 2011 Sebastian Kügler <sebas@kde.org>
    Copyright 2010 Richard Moore <rich@kde.org>

    This library is free software; you can redistribute it and/or modify it
    under the terms of the GNU Library General Public License as published by
    the Free Software Foundation; either version 2 of the License, or (at your
    option) any later version.

    This library is distributed in the hope that it will be useful, but WITHOUT
    ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
    FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Library General Public
    License for more details.

    You should have received a copy of the GNU Library General Public License
    along with this library; see the file COPYING.LIB.  If not, write to the
    Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
    02110-1301, USA.
*/



#include <QtCore/QUrl>
#include <QtCore/QSize>
#include <QtGui/QPainter>
#include <QtWebKit/QWebPage>
#include <QtWebKit/QWebFrame>

#include "kwebthumbnailer.h"
#include <kimagecache.h>
#include <KTemporaryFile>
#include <KLocalizedString>

#include <kdebug.h>

class KWebThumbnailerPrivate
{
public:
    KWebThumbnailerPrivate() : page(0) {
    }

    QWebPage *page;
    QImage thumbnail;
    QSize size;
    QUrl url;
    QString fileName;
    QString status;
    QString errorText;
    KImageCache* cache;
};

KWebThumbnailer::KWebThumbnailer( QObject *parent )
    : QObject( parent ),
      d( new KWebThumbnailerPrivate )
{
}

KWebThumbnailer::KWebThumbnailer( const QUrl &url, const QSize &size, QObject *parent )
    : QObject( parent ),
      d( new KWebThumbnailerPrivate )
{
    d->url = url;
    d->size = size;
    d->status = "idle";
    d->cache = new KImageCache("kwebthumbnailer", 1048576); // 10 MByte
    kDebug() << "cache created." << d->cache->timestamp();

    // filename is set later.
}

KWebThumbnailer::~KWebThumbnailer()
{
    delete d->cache;
    delete d->page;
    delete d;
}

QUrl KWebThumbnailer::url()
{
    return d->url;
}

void KWebThumbnailer::setUrl( const QUrl &url )
{
    d->url = url;
}

QSize KWebThumbnailer::size()
{
    return d->size;
}

void KWebThumbnailer::setSize( const QSize &size )
{
    d->size = size;
}

QString KWebThumbnailer::fileName()
{
    return d->fileName;
}

QString KWebThumbnailer::status()
{
    return d->status;
}

void KWebThumbnailer::start()
{
    d->thumbnail = QImage(d->size, QImage::Format_ARGB32_Premultiplied);
    if (d->cache->findImage(d->url.toString(), &(d->thumbnail))) {
        // cache hit
        d->status = i18nc("status of thumbnail loader", "Cached");
        kDebug() << "cache hit for " << d->url;
        saveThumbnail();
        return;
    }
    kDebug() << "not cached, loading" << d->url;
    d->status = i18nc("status of thumbnail loader", "Loading...");

    d->page = new QWebPage( this );
    d->page->mainFrame()->setScrollBarPolicy( Qt::Horizontal, Qt::ScrollBarAlwaysOff );
    d->page->mainFrame()->setScrollBarPolicy( Qt::Vertical, Qt::ScrollBarAlwaysOff );
    d->page->mainFrame()->load( d->url );

    connect(d->page, SIGNAL(loadFinished(bool)), this, SLOT(completed(bool)));
}

void KWebThumbnailer::completed( bool success )
{
    if ( !success ) {
        delete d->page;
        d->page = 0;
        d->thumbnail = QImage(d->size, QImage::Format_ARGB32_Premultiplied);
        d->thumbnail.fill( Qt::transparent );
        // FIXME: fallback pixmap
        d->status = "failed";
        d->errorText = i18n("Unknown error");
        emit done(false);

        return;
    }

    // find proper size, we stick to sensible aspect ratio
    QSize size = d->page->mainFrame()->contentsSize();
    size.setHeight( size.width() * d->size.height() / d->size.width() );

    // create the target surface
    d->thumbnail = QImage( d->size, QImage::Format_ARGB32_Premultiplied );
    d->thumbnail.fill( Qt::transparent );

    // render and rescale
    QPainter p(&(d->thumbnail));
    d->page->setViewportSize( d->page->mainFrame()->contentsSize() );
    d->page->mainFrame()->render( &p );
    p.end();

    delete d->page;
    d->page = 0;
    saveThumbnail();
}

void KWebThumbnailer::saveThumbnail()
{
    if (d->fileName.isEmpty()) {
        KTemporaryFile tmp;
        tmp.setSuffix(".png");
        tmp.open();
        d->fileName = tmp.fileName();
        tmp.close();
        kDebug() << "saving as ..." << d->fileName;
    }


    d->thumbnail.save(fileName());
    kDebug() << "saved image to:" << fileName();
    d->cache->insertImage(d->url.toString(), d->thumbnail);
    kDebug() << "image inserted into CACHE:" << d->url.toString() << d->thumbnail.size();
    d->status = "loaded";
    d->errorText = i18nc("status of thumbnail loader", "Loaded");

    emit done(true);
}

QImage KWebThumbnailer::thumbnail() const
{
    return d->thumbnail;
}

bool KWebThumbnailer::isValid() const
{
    return d->thumbnail.isNull();
}


