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
#include "previewcontainer.h"

using namespace KIO;


K_EXPORT_PLASMA_DATAENGINE(previewengine, PreviewEngine)


PreviewEngine::PreviewEngine(QObject* parent, const QVariantList& args)
    : Plasma::DataEngine(parent)
{
    Q_UNUSED(args);
    setMaxSourceCount(64); // Guard against loading too many connections
    init();
}

void PreviewEngine::init()
{
    m_imageCache = new KImageCache("plasma_engine_preview", 1048576); // 10 MByte
    setData("fallback", "fallbackImage", KIcon("image-loading").pixmap(QSize(180, 120)).toImage());
}

PreviewEngine::~PreviewEngine()
{
}

KImageCache* PreviewEngine::imageCache() const
{
    return m_imageCache;
}

bool PreviewEngine::sourceRequestEvent(const QString &name)
{
    // Check if the url is valid
    kDebug() << "name: " << name;
    QUrl url = QUrl(name);
    if (!url.isValid()) {
        kWarning() << "Not a URL:" << name;
        //return false;
    }

    PreviewContainer *container = qobject_cast<PreviewContainer *>(containerForSource(name));

    if (!container) {
        //the name and the url are separate because is not possible to know the original string encoding given a QUrl
        container = new PreviewContainer(name, url, this);
        addSource(container);
    }

    return true;
}

#include "previewengine.moc"
