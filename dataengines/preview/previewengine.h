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


#ifndef PREVIEWENGINE_H
#define PREVIEWENGINE_H

#include <plasma/dataengine.h>

class KWebThumbnailer;

class PreviewEnginePrivate;

class PreviewEngine : public Plasma::DataEngine
{
    Q_OBJECT

    public:
        PreviewEngine(QObject* parent, const QVariantList& args);
        ~PreviewEngine();
        QStringList sources() const;
        virtual void init();

    private Q_SLOTS:
        void thumbnailerDone(bool success);


    protected:
        bool sourceRequestEvent(const QString &name);
        QLatin1String sizeString(const QSize &s);
        QString thumbnailerSource(KWebThumbnailer* nailer);
        void updateData(KWebThumbnailer* nailer);

        PreviewEnginePrivate* d;
};

K_EXPORT_PLASMA_DATAENGINE(previewengine, PreviewEngine)

#endif
