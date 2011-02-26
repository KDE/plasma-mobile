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
    // filename is set later.
}

KWebThumbnailer::~KWebThumbnailer()
{
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
    d->status = "loading";
    d->page = new QWebPage( this );
    d->page->mainFrame()->setScrollBarPolicy( Qt::Horizontal, Qt::ScrollBarAlwaysOff );
    d->page->mainFrame()->setScrollBarPolicy( Qt::Vertical, Qt::ScrollBarAlwaysOff );
    d->page->mainFrame()->load( d->url );

    connect( d->page, SIGNAL(loadFinished(bool)), this, SLOT(completed(bool)) );
}

void KWebThumbnailer::completed( bool success )
{
    if ( !success ) {
        delete d->page;
        d->page = 0;
        d->thumbnail = QImage();
        d->status = "failed";
        d->errorText = i18n("Unknown error");
        emit done(false);

        return;
    }

    // find proper size, we stick to sensible aspect ratio
    QSize size = d->page->mainFrame()->contentsSize();
    size.setHeight( size.width() * d->size.height() / d->size.width() );

    // create the target surface
    d->thumbnail = QImage( size, QImage::Format_ARGB32_Premultiplied );
    d->thumbnail.fill( Qt::transparent );

    // render and rescale
    QPainter p( &(d->thumbnail) );
    d->page->setViewportSize( d->page->mainFrame()->contentsSize() );
    d->page->mainFrame()->render( &p );
    p.end();

    d->thumbnail = d->thumbnail.scaled( d->size, Qt::KeepAspectRatioByExpanding, Qt::SmoothTransformation );

    delete d->page;
    d->page = 0;

    if (d->fileName.isEmpty()) {
        KTemporaryFile tmp;
        tmp.setSuffix(".png");
        tmp.open();
        d->fileName = tmp.fileName();
        tmp.close();
        kDebug() << "OOO OOO OOO Image saved as " << d->fileName;
        //d->fileName = "file:///tmp/bla.png";
    }


    d->thumbnail.save(fileName());
    kDebug() << "SAVED IMAGE TO:" << fileName();
    d->status = i18nc("status of thumbnail loader", "Loaded");

    emit done(success);
}

QImage KWebThumbnailer::thumbnail() const
{
    return d->thumbnail;
}

bool KWebThumbnailer::isValid() const
{
    return d->thumbnail.isNull();
}


