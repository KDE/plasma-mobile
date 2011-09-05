/*
    Copyright 2011 Sebastian Kügler <sebas@kde.org>
    Copyright 2011 Marco Martin <mart@kde.org>

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


#ifndef PREVIEWENGINE_H
#define PREVIEWENGINE_H

#include <plasma/dataengine.h>
#include <QImage>
#include "kio/jobclasses.h" // for KIO::JobFlags
#include "kio/job.h"
#include "kio/scheduler.h"

using namespace KIO;

class KWebThumbnailer;

class KImageCache;

class PreviewEngine : public Plasma::DataEngine
{
    Q_OBJECT

public:
    PreviewEngine(QObject* parent, const QVariantList& args);
    ~PreviewEngine();
    virtual void init();

    KImageCache* imageCache() const;

protected:
    bool sourceRequestEvent(const QString &name);

private:
    KImageCache* m_imageCache;
};

#endif
