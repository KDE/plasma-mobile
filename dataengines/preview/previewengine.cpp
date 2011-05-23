/*
    Copyright 2011 Sebastian Kügler <sebas@kde.org>

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

//#include <KFileMetaInfo>
//#include <KIcon>

#include <KIO/PreviewJob>
#include <KIcon>
#include <KImageCache>
#include <KFileItem>
#include <KGlobal>
#include <KStandardDirs>
#include <KTemporaryFile>
#include <KRun>
#include <QWidget>

#include "previewengine.h"
#include "kwebthumbnailer.h"

using namespace KIO;

class PreviewEnginePrivate
{
public:
    int i;
    QSize previewSize;
    QHash<QString, KWebThumbnailer*> webworkers;
    QHash<QString, KIO::PreviewJob*> workers;
    QHash<KIO::Job*, QString> sources;
    KImageCache* cache;
};


PreviewEngine::PreviewEngine(QObject* parent, const QVariantList& args)
    : Plasma::DataEngine(parent)
{
    Q_UNUSED(args);
    d = new PreviewEnginePrivate;
    d->previewSize = QSize(180, 120);
    d->i = 0;
    setMaxSourceCount(64); // Guard against loading too many connections
    init();
}

void PreviewEngine::init()
{
    d->cache = new KImageCache("plasma_engine_preview", 1048576); // 10 MByte
}

PreviewEngine::~PreviewEngine()
{
    delete d;
}

QStringList PreviewEngine::sources() const
{
    return QStringList();
}

bool PreviewEngine::sourceRequestEvent(const QString &name)
{
    // Check if the url is valid, and start a MimetypeJob
    // to find out what kind of preview we need
    if (sources().contains(name)) {
        return true;
    }
    if (!sources().contains("fallback")) {
        //setData("fallback", "fallbackImage", KIcon("image-loading").pixmap(QSize(180, 120)).toImage());
        setData("fallback", "fallbackImage", QImage("file://home/sebas/Documents/wallpaper.png"));
    }
    QUrl url = QUrl(name);
    if (!url.isValid()) {
        kWarning() << "Not a URL:" << name;
        return false;
    }

    if (d->webworkers.keys().contains(name) || d->workers.keys().contains(name)) {
        return true; // already got preview or at least tried to get it
    }
    QImage preview = QImage(d->previewSize, QImage::Format_ARGB32_Premultiplied);
    if (d->cache->findImage(name, &preview)) {
        // cache hit
        setPreview(name, preview);
        return true;
    }

    // It may be a directory or a file, let's stat
    KIO::JobFlags flags = KIO::HideProgressInfo;
    KIO::MimetypeJob *job = KIO::mimetype(url, flags);
    d->sources[job] = name;
    QObject::connect(job, SIGNAL(mimetype(KIO::Job *, const QString&)),
                          SLOT(mimetypeRetrieved(KIO::Job *, const QString&)));
    return true;
}

void PreviewEngine::mimetypeRetrieved(KIO::Job* job, const QString &mimetype)
{
    KIO::TransferJob* mimejob = dynamic_cast<KIO::TransferJob*>(job);
    if (!mimejob) {
        return;
    }
    QString source = mimejob->url().url();
    source = d->sources[job];
    if (!mimetype.isEmpty() && !mimejob->error()) {
        // Make job reusable by keeping the connection open:
        // We want to retrieve the target next to create a preview
        mimejob->putOnHold();
        KIO::Scheduler::publishSlaveOnHold();
    }

    if (mimetype == "text/html") {
        if (!(d->webworkers.keys().contains(source))) {
            KWebThumbnailer* wtn = new KWebThumbnailer(QUrl(source), d->previewSize, source, this);
            connect(wtn, SIGNAL(done(bool)), SLOT(thumbnailerDone(bool)));
            wtn->start();
            d->webworkers[source] = wtn;
        }
    } else {
        if (!(d->workers.keys().contains(source))) {
            // KIO::PreviewJob: http://api.kde.org/4.x-api/kdelibs-apidocs/kio/html/classKIO_1_1PreviewJob.html
            KFileItem kfile = KFileItem(mimejob->url(), mimetype, KFileItem::Unknown);
            KFileItemList list;
            list << kfile;
            KIO::PreviewJob *job = new KIO::PreviewJob(list, d->previewSize, 0);
            connect(job, SIGNAL(gotPreview(const KFileItem&, const QPixmap&)), SLOT(previewUpdated(const KFileItem&, const QPixmap&)));
            connect(job, SIGNAL(failed(const KFileItem&)), SLOT(previewJobFailed(const KFileItem&)));
            connect(job, SIGNAL(result(KJob*)), SLOT(previewResult(KJob*)));
            d->workers[source] = job;
            job->start();
        }
    }
}

QString PreviewEngine::thumbnailerSource(KWebThumbnailer* nailer)
{
    return nailer->source();
}

void PreviewEngine::thumbnailerDone(bool success)
{
    KWebThumbnailer* wtn = static_cast<KWebThumbnailer*>(sender());
    if (!wtn) {
        kWarning() << "wrong sender";
        return;
    }
    if (!success) {
        setData(wtn->source(), "status", "failed");
        return;
    }
    updateData(wtn);
}

void PreviewEngine::updateData(KWebThumbnailer* wtn)
{
    setData(thumbnailerSource(wtn), "status", wtn->status());
    setData(thumbnailerSource(wtn), "url", wtn->url().toString());
    setData(thumbnailerSource(wtn), "thumbnail", wtn->thumbnail());
    scheduleSourcesUpdated();
}

void PreviewEngine::previewJobFailed(const KFileItem &item)
{
    setData(item.url().url(), "status", "failed");
    kWarning() << "preview failed for" << item.url().url();
}

void PreviewEngine::previewResult(KJob* job)
{
    Q_UNUSED( job );
    //kDebug() << "job result:" << job->errorText() << "success?" << (job->error() == 0);
}

void PreviewEngine::previewUpdated(const KFileItem &item, const QPixmap &preview)
{
    setPreview(item.url().url(), preview.toImage());
}


void PreviewEngine::setPreview(const QString &source, QImage preview)
{
    setData(source, "status", "done");
    setData(source, "url", source);
    setData(source, "thumbnail", preview);
    scheduleSourcesUpdated();
}

#include "previewengine.moc"
