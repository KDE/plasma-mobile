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

#include "metadataengine.h"

using namespace KIO;

class MetadataEngineprivate
{
public:
    int i;
    QSize previewSize;
    QHash<QString, KIO::PreviewJob*> workers;
};


MetadataEngine::MetadataEngine(QObject* parent, const QVariantList& args)
    : Plasma::DataEngine(parent)
{
    Q_UNUSED(args);
    d = new MetadataEngineprivate;
    d->previewSize = QSize(180, 120);
    d->i = 0;
    setMaxSourceCount(64); // Guard against loading too many connections
    init();
}

void MetadataEngine::init()
{
    kDebug() << "init.";
}

MetadataEngine::~MetadataEngine()
{
    delete d;
}

QStringList MetadataEngine::sources() const
{
    //return QStringList();
    return QStringList() << "https://wiki.ubuntu.com/X/Config/Input" << "file:///home/sebas/Documents/Curacao/wallpaper.jpg";
}

bool MetadataEngine::sourceRequestEvent(const QString &name)
{
    return true;
}

void MetadataEngine::mimetypeRetrieved(KIO::Job* job, const QString &mimetype)
{
}

#include "metadataengine.moc"
