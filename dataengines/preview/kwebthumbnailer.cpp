#include <QtCore/QUrl>
#include <QtCore/QSize>
#include <QtGui/QPainter>
#include <QtWebKit/QWebPage>
#include <QtWebKit/QWebFrame>

#include "kwebthumbnailer.h"

class KWebThumbnailerPrivate
{
public:
    KWebThumbnailerPrivate() : page(0) {
    }

    QWebPage *page;
    QImage thumbnail;
    QSize size;
    QUrl url;
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

void KWebThumbnailer::start()
{
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


