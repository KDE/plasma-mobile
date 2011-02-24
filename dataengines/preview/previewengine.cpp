/*
    Copyright 2010 Sebastian Kügler <sebas@kde.org>

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

#include "previewengine.h"
#include "kwebthumbnailer.h"


class PreviewEnginePrivate
{
public:
    int i;
    QHash<QString, KWebThumbnailer*> workers;
};


PreviewEngine::PreviewEngine(QObject* parent, const QVariantList& args)
    : Plasma::DataEngine(parent)
{
    Q_UNUSED(args);
    d = new PreviewEnginePrivate;

    d->i = 0;
    setMaxSourceCount(64); // Guard against loading too many connections

    //init();
}

void PreviewEngine::init()
{
    kDebug() << "init.";
}

PreviewEngine::~PreviewEngine()
{
}

QStringList PreviewEngine::sources() const
{
    return QStringList() << "https://wiki.ubuntu.com/X/Config/Input";
}

bool PreviewEngine::sourceRequestEvent(const QString &name)
{
    kDebug() << "Source requested:" << name << sources();
    //setData(name, DataEngine::Data());

    if (name.startsWith("http")) { // lame check.
        KWebThumbnailer* wtn = new KWebThumbnailer(QUrl(name), QSize(180, 120), this);
        //setData(thumbnailerSource(wtn), "status", "working");
        connect(wtn, SIGNAL(done(bool)), SLOT(thumbnailerDone(bool)));
        wtn->start();
        updateData(wtn);
        return true;
    }

    return false;
}

QLatin1String PreviewEngine::sizeString(const QSize &s)
{
    //return QLatin1String("320x320");
    return QLatin1String("thumbnail");
    //return QString("%1x%2").arg(s.width(), s.height()).toLatin1();
}

QString PreviewEngine::thumbnailerSource(KWebThumbnailer* nailer)
{
    return nailer->url().toString();
    //return QLatin1String("320x320");
    //return QString("%1x%2").arg(s.width(), s.height()).toLatin1();
}

void PreviewEngine::thumbnailerDone(bool success)
{
    //kDebug() << "done...";
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
    //setData(wtn->url().toString(), key, image);
    kDebug() << "Thumbnail set:" << wtn->url() << key << image.height() << image.width();
    updateData(wtn);
}

void PreviewEngine::updateData(KWebThumbnailer* wtn)
{
    //setData(thumbnailerSource(wtn), "status", wtn->status());
    //setData(thumbnailerSource(wtn), "url", wtn->url().toString());
    setData(thumbnailerSource(wtn), "fileName", wtn->fileName());
    //setData(thumbnailerSource(wtn), "thumbnail", wtn->thumbnail());
    scheduleSourcesUpdated();
}

#include "previewengine.moc"
