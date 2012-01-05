/***************************************************************************
 *                                                                         *
 *   Copyright 2011 Sebastian Kügler <sebas@kde.org>                       *
 *   Copyright 2011 Marco Martin <mart@kde.org>                            *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA .        *
 ***************************************************************************/

#include "kdeclarativeview.h"
#include "dataenginebindings_p.h"

#include <QDeclarativeContext>
#include <QDeclarativeEngine>
#include <QDeclarativeItem>
#include <QGLWidget>

#include <KDebug>

#include  <kdeclarative.h>

#include <Plasma/Package>

class KDeclarativeViewPrivate
{
public:
    KDeclarativeViewPrivate()
        : useGL(false)
    {}

    KDeclarative kdeclarative;
    Plasma::PackageStructure::Ptr structure;
    Plasma::Package *package;
    QString packageName;
    bool useGL;
};

KDeclarativeView::KDeclarativeView(QWidget *parent)
    : QDeclarativeView(parent),
      d(new KDeclarativeViewPrivate)
{
    // avoid flicker on show
    setAttribute(Qt::WA_OpaquePaintEvent);
    setAttribute(Qt::WA_NoSystemBackground);
    viewport()->setAttribute(Qt::WA_OpaquePaintEvent);
    viewport()->setAttribute(Qt::WA_NoSystemBackground);

    setResizeMode(QDeclarativeView::SizeRootObjectToView);

    d->kdeclarative.setDeclarativeEngine(engine());
    d->kdeclarative.initialize();
    //binds things like kconfig and icons
    d->kdeclarative.setupBindings();
    QScriptEngine *scriptEngine = d->kdeclarative.scriptEngine();
    registerDataEngineMetaTypes(scriptEngine);

    d->structure = Plasma::PackageStructure::load("Plasma/Generic");

    show();
}

KDeclarativeView::~KDeclarativeView()
{
}


void KDeclarativeView::setPackageName(const QString &packageName)
{
    d->package = new Plasma::Package(QString(), packageName, d->structure);
    d->packageName = packageName;
    setSource(QUrl(d->package->filePath("mainscript")));
}

QString KDeclarativeView::packageName() const
{
    return d->packageName;
}

void KDeclarativeView::setPackage(Plasma::Package *package)
{
    if (!package || package == d->package) {
        return;
    }

    d->package = package;
    d->packageName = package->metadata().pluginName();
    setSource(QUrl(d->package->filePath("mainscript")));
}

Plasma::Package *KDeclarativeView::package() const
{
    return d->package;
}

void KDeclarativeView::setUseGL(const bool on)
{
#ifndef QT_NO_OPENGL
    if (on) {
      QGLWidget *glWidget = new QGLWidget;
      glWidget->setAutoFillBackground(false);
      setViewport(glWidget);
    }
#endif
    d->useGL = on;
}

bool KDeclarativeView::useGL() const
{
    return d->useGL;
}

#include "kdeclarativeview.moc"
