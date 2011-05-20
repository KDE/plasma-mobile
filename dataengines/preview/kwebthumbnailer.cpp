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
#include <KIcon>
#include <kimagecache.h>
#include <KGlobal>
#include <KStandardDirs>
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
    QString source;
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

KWebThumbnailer::KWebThumbnailer(const QUrl &url, const QSize &size,  const QString &source, QObject *parent)
    : QObject( parent ),
      d( new KWebThumbnailerPrivate )
{
    d->source = source;
    d->url = url;
    d->fileName = fileName();
    d->size = size;
    d->status = "idle";
    d->cache = new KImageCache("plasma_engine_preview", 1048576); // 10 MByte
}

KWebThumbnailer::~KWebThumbnailer()
{
    delete d->cache;
    delete d;
}

QUrl KWebThumbnailer::url()
{
    return d->url;
}

QString KWebThumbnailer::source()
{
    return d->source;
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
    if (d->fileName.isEmpty()) {
        QString tmpFile = KGlobal::dirs()->findDirs("tmp", QString())[0];
        QString u = d->source;
        if (u.endsWith('/')) {
            u.chop(1);
        }
        tmpFile.append("previewengine_");
        tmpFile.append(QString::number(qHash(u)));
        tmpFile.append(".png");
        d->fileName = tmpFile;
    }
    return d->fileName;
}

QString KWebThumbnailer::status()
{
    return d->status;
}

void KWebThumbnailer::start()
{
    // check if the thumbnail is already cached, if not, create a new one
    d->thumbnail = QImage(d->size, QImage::Format_ARGB32_Premultiplied);
    if (d->cache->findImage(d->url.toString(), &(d->thumbnail))) {
        // cache hit
        d->status = i18nc("status of thumbnail loader", "Cached");
        kDebug() << "cache hit for " << d->url.toString();
        setThumbnail();
        return;
    }
    d->status = i18nc("status of thumbnail loader", "Loading...");

    d->page = new QWebPage( this );
    d->page->mainFrame()->setScrollBarPolicy( Qt::Horizontal, Qt::ScrollBarAlwaysOff );
    d->page->mainFrame()->setScrollBarPolicy( Qt::Vertical, Qt::ScrollBarAlwaysOff );
    d->page->mainFrame()->load( d->url );

    connect(d->page, SIGNAL(loadFinished(bool)), this, SLOT(completed(bool)));
}

void KWebThumbnailer::completed( bool success )
{
    if (!success) {
        delete d->page;
        d->page = 0;
        d->thumbnail = QImage(d->size, QImage::Format_ARGB32_Premultiplied);
        d->thumbnail.fill( Qt::transparent );
        // FIXME: fallback pixmap
        d->thumbnail = KIcon("internet-web-browser").pixmap(d->size).toImage();
        d->status = "failed";
        d->errorText = i18n("Unknown error");
        emit done(true);

        return;
    }

    // find proper size, we stick to sensible aspect ratio
    QSize size = d->page->mainFrame()->contentsSize();
    size.setHeight( size.width() * d->size.height() / d->size.width() );

    // create the target surface
    d->thumbnail = QImage(size, QImage::Format_ARGB32_Premultiplied ); // clip here
    d->thumbnail.fill( Qt::transparent );

    // render and rescale
    QPainter p(&(d->thumbnail));
    d->page->setViewportSize( d->page->mainFrame()->contentsSize() );
    d->page->mainFrame()->render( &p );
    p.end();

    delete d->page;
    d->page = 0;

    d->thumbnail = d->thumbnail.scaled(d->size,
                                        Qt::KeepAspectRatioByExpanding,
                                        Qt::SmoothTransformation);
    setThumbnail();
}

void KWebThumbnailer::setThumbnail()
{
    // is it already in the cache?
    if (!d->cache->contains(d->source)) {
        d->cache->insertImage(d->source, d->thumbnail);
        kDebug() << "inserted into KIC" << d->source;
    }
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


