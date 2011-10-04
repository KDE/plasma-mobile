/*
 * Copyright 2011 Marco Martin <mart@kde.org>
 * Copyright 2011 Sebastian Kügler <sebas@kde.org>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Library General Public License version 2 as
 * published by the Free Software Foundation
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Library General Public License for more details
 *
 * You should have received a copy of the GNU Library General Public
 * License along with this program; if not, write to the
 * Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#include "previewcontainer.h"
#include "previewengine.h"
#include "kwebthumbnailer.h"

#include <KDebug>
#include <KIcon>
#include <KImageCache>


PreviewContainer::PreviewContainer(const QString &name,
                                   const QUrl &url,
                                   QObject *parent)
    : Plasma::DataContainer(parent),
      m_url(url)
{
    setObjectName(name);
    m_previewSize = QSize(180, 120);
    m_previewEngine = static_cast<PreviewEngine *>(parent);

    // Check if the image is in the cache, if so return it
    QImage preview = QImage(m_previewSize, QImage::Format_ARGB32_Premultiplied);
    if (m_previewEngine->imageCache()->findImage(name, &preview)) {
        // cache hit
        setData("status", "done");
        setData("url", m_url);
        setData("thumbnail", preview);
        checkForUpdate();
        return;
    }

    // Set fallbackimage while loading
    m_fallbackImage = KIcon("image-loading").pixmap(QSize(64, 64)).toImage();
    m_fallbackImage = m_fallbackImage.copy(QRect(QPoint(-120,0), m_previewSize));
    setData("status", "loading");
    setData("url", m_url);
    setData("thumbnail", m_fallbackImage);
    checkForUpdate();

    // It may be a directory or a file, let's stat
    KIO::JobFlags flags = KIO::HideProgressInfo;
    m_mimeJob = KIO::mimetype(url, flags);
    connect(m_mimeJob, SIGNAL(mimetype(KIO::Job *, const QString&)),
            this, SLOT(mimetypeRetrieved(KIO::Job *, const QString&)));
}

PreviewContainer::~PreviewContainer()
{
}

void PreviewContainer::mimetypeRetrieved(KIO::Job* job, const QString &mimetype)
{
    Q_UNUSED(job)

    if (mimetype.isEmpty() || m_mimeJob->error()) {
        setData("status", "failed");
        //kDebug() << "mimejob failed" << m_mimeJob->url();
        return;
    } else {
        // Make job reusable by keeping the connection open:
        // We want to retrieve the target next to create a preview
        m_mimeJob->putOnHold();
        KIO::Scheduler::publishSlaveOnHold();
    }

//    if (mimetype == "text/html") {
    if (false) {
        m_webThumbnailer = new KWebThumbnailer(m_url, m_previewSize, m_url.toString(), this);

        connect(m_webThumbnailer, SIGNAL(done(bool)), SLOT(webThumbnailerDone(bool)));

        m_webThumbnailer->start();
    } else {
        // KIO::PreviewJob: http://api.kde.org/4.x-api/kdelibs-apidocs/kio/html/classKIO_1_1PreviewJob.html
        KFileItem kfile = KFileItem(m_url, mimetype, KFileItem::Unknown);
        KFileItemList list;
        list << kfile;
        m_job = new KIO::PreviewJob(list, m_previewSize, 0);

        connect(m_job, SIGNAL(gotPreview(const KFileItem&, const QPixmap&)),
                SLOT(previewUpdated(const KFileItem&, const QPixmap&)));
        connect(m_job, SIGNAL(failed(const KFileItem&)),
                SLOT(previewJobFailed(const KFileItem&)));
        connect(m_job, SIGNAL(result(KJob*)), SLOT(previewResult(KJob*)));

        m_job->start();
    }
}

void PreviewContainer::webThumbnailerDone(bool success)
{
    if (!success) {
        setData("status", "failed");
        checkForUpdate();
        return;
    }

    setData("status", m_webThumbnailer->status());
    setData("url", m_url);
    setData("thumbnail", m_webThumbnailer->thumbnail());
    m_previewEngine->imageCache()->insertImage(objectName(), m_webThumbnailer->thumbnail());
    checkForUpdate();
}


void PreviewContainer::previewJobFailed(const KFileItem &item)
{
    Q_UNUSED(item)

    setData("status", "failed");
    kWarning() << "preview failed for" << m_url;
}

void PreviewContainer::previewResult(KJob* job)
{
    Q_UNUSED( job );
    //kDebug() << "job result:" << job->errorText() << "success?" << (job->error() == 0);
}

void PreviewContainer::previewUpdated(const KFileItem &item, const QPixmap &preview)
{
    Q_UNUSED(item)

    setData("status", "done");
    setData("url", m_url);
    setData("thumbnail", preview.toImage());
    m_previewEngine->imageCache()->insertImage(objectName(), preview.toImage());
    checkForUpdate();
}

#include "previewcontainer.moc"
