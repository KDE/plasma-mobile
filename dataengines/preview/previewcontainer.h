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

#ifndef PREVIEWCONTAINER_H
#define PREVIEWCONTAINER_H

// plasma
#include <Plasma/DataContainer>
#include "kio/jobclasses.h" // for KIO::JobFlags
#include "kio/job.h"
#include "kio/scheduler.h"
#include "kio/previewjob.h"
#include <KFileItem>

class PreviewEngine;

class PreviewContainer : public Plasma::DataContainer
{
    Q_OBJECT

public:
    PreviewContainer(const QString &name, const QUrl &url, QObject *parent = 0);
    ~PreviewContainer();

private Q_SLOTS:
    void mimetypeRetrieved(KIO::Job* job, const QString &mimetype);
    void previewUpdated(const KFileItem &item, const QPixmap &preview);
    void previewJobFailed(const KFileItem &item);
    void previewResult(KJob* job);

private:
    QSize m_previewSize;
    QImage m_fallbackImage;
    KIO::PreviewJob *m_job;
    KIO::MimetypeJob *m_mimeJob;
    QUrl m_url;
    QString m_name;
    PreviewEngine *m_previewEngine;
};

#endif // PREVIEWCONTAINER_H
