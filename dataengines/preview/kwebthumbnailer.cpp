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
    d->status = i18nc("status of thumbnail loader", "Idle");
    //d->fileName = "/tmp/bla.png";
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
    d->status = i18nc("status of thumbnail loader", "Loading...");
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
        d->status = i18nc("status of thumbnail loader", "Failed");
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


