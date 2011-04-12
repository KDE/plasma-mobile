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
#include <KFileItem>
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
    kDebug() << "init.";
}

PreviewEngine::~PreviewEngine()
{
    delete d;
}

QStringList PreviewEngine::sources() const
{
    return QStringList();
    //return QStringList() << "https://wiki.ubuntu.com/X/Config/Input" << "file:///home/sebas/Documents/Curacao/wallpaper.jpg";
}

bool PreviewEngine::sourceRequestEvent(const QString &name)
{
    // Check if the url is valid, and start a MimetypeJob
    // to find out what kind of preview we need
    QUrl url = QUrl(name);
    if (!url.isValid()) {
        kWarning() << "Not a URL:" << name;
        return false;
    }
    if (d->webworkers.keys().contains(name) || d->workers.keys().contains(name)) {
        return true; // already got preview or at least tried to get it
    }
    // It may be a directory or a file, let's stat
    KIO::JobFlags flags = KIO::HideProgressInfo;
    KIO::MimetypeJob *job = KIO::mimetype(url, flags);
    QObject::connect(job, SIGNAL(mimetype(KIO::Job *, const QString&)),
                          SLOT(mimetypeRetrieved(KIO::Job *, const QString&)));
    return true;

}

void PreviewEngine::mimetypeRetrieved(KIO::Job* job, const QString &mimetype)
{
    KIO::TransferJob* mimejob = dynamic_cast<KIO::TransferJob*>(job);

    //KIO::MimetypeJob* mimejob = qobject_cast<KIO::MimetypeJob*>(job);
    if (!mimejob) {
        return;
    }
    QString source = mimejob->url().url();
    kDebug() << "mimetype retrieved:" << mimejob->url().url() << mimetype;
    if (!mimetype.isEmpty() && !mimejob->error()) {
        // Make job reusable by keeping the connection open:
        // We want to retrieve the target next to create a preview
        mimejob->putOnHold();
        KIO::Scheduler::publishSlaveOnHold();
    }

    if (mimetype == "text/html") {
        if (!(d->webworkers.keys().contains(source))) {
            kDebug() << "Starting webthumbnailer" << source;
            KWebThumbnailer* wtn = new KWebThumbnailer(QUrl(source), d->previewSize, this);
            connect(wtn, SIGNAL(done(bool)), SLOT(thumbnailerDone(bool)));
            wtn->start();
            d->webworkers[source] = wtn;
            //updateData(wtn);
        }
    } else {
        if (!(d->workers.keys().contains(source))) {
            kDebug() << "Starting previewjob" << source;
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

QLatin1String PreviewEngine::sizeString(const QSize &s)
{
    Q_UNUSED(s)
    return QLatin1String("thumbnail");
    //return QString("%1x%2").arg(s.width(), s.height()).toLatin1();
}

QString PreviewEngine::thumbnailerSource(KWebThumbnailer* nailer)
{
    return nailer->url().toString();
}

void PreviewEngine::thumbnailerDone(bool success)
{
    KWebThumbnailer* wtn = static_cast<KWebThumbnailer*>(sender());
    if (!wtn) {
        kWarning() << "wrong sender";
        return;
    }
    if (!success) {
        setData(thumbnailerSource(wtn), "status", "failed");
        return;
    }
    QLatin1String key = sizeString(wtn->size());
    QImage image = wtn->thumbnail();
    //kDebug() << "Thumbnail set:" << wtn->url() << key << image.height() << image.width();
    updateData(wtn);
}

void PreviewEngine::updateData(KWebThumbnailer* wtn)
{
    setData(thumbnailerSource(wtn), "status", wtn->status());
    setData(thumbnailerSource(wtn), "url", wtn->url().toString());
    setData(thumbnailerSource(wtn), "fileName", wtn->fileName());
    setData(thumbnailerSource(wtn), "thumbnail", wtn->thumbnail());
    if (!wtn->fileName().isEmpty()) {
        kDebug() << "sources updated." << wtn->fileName();
        scheduleSourcesUpdated();
    }
}

void PreviewEngine::previewJobFailed(const KFileItem &item)
{
    setData(item.url().url(), "status", "failed");
    kDebug() << "preview failed for" << item.url().url();
}

void PreviewEngine::previewResult(KJob* job)
{
    //setData(item.url().url(), "errorText", job->errorText());
    kDebug() << "job result:" << job->errorText() << "success?" << (job->error() == 0);
}

void PreviewEngine::previewUpdated(const KFileItem &item, const QPixmap &preview)
{
    //kDebug() << "preview for" << item.url().url() << "is in." << preview.width() << preview.height();
    QString fileName;

    KTemporaryFile* tmp = new KTemporaryFile();
    tmp->setSuffix(".png");
    //if (tmp->open()) kDebug() << "file opened";
    fileName = tmp->fileName();
    tmp->close();
    delete tmp;

    //fileName = "/tmp/thumbnail.png";
    if (preview.save(fileName)) {
        //kDebug() << "pixmap saved, or so it says";
        setData(item.url().url(), "status", "done");
        setData(item.url().url(), "fileName", fileName);
        setData(item.url().url(), "url", item.url().url());
        setData(item.url().url(), "thumbnail", preview.toImage());
        //if (!fileName().isEmpty()) scheduleSourcesUpdated();
    } else {
        //kDebug() << "saving failed";
        setData(item.url().url(), "status", "failed");
    }
    //kDebug() << "==== File exists?" << QFile(fileName).exists();
    kDebug() << "XXX XXX XXX Pixmap saved as " << fileName << item.url().url();
    //KRun::runUrl(KUrl(fileName), "image/png", new QWidget());
    // setData...
    scheduleSourcesUpdated();
}

#include "previewengine.moc"
