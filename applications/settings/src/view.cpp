/***************************************************************************
 *                                                                         *
 *   Copyright 2011 Sebastian Kügler <sebas@kde.org>                       *
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

#include "view.h"

#include <QQmlContext>
#include <QQmlEngine>
#include <QQuickItem>
#include <QTimer>

//#include <KConfigGroup>
#include <KStandardDirs>
#include "Plasma/Package"

#include <kdeclarative.h>

View::View(const QString &module, QWidget *parent)
    : QQuickView(parent),
    m_package(0),
    m_settingsRoot(0)
{
    // avoid flicker on show
    setAttribute(Qt::WA_OpaquePaintEvent);
    setAttribute(Qt::WA_NoSystemBackground);
    viewport()->setAttribute(Qt::WA_OpaquePaintEvent);
    viewport()->setAttribute(Qt::WA_NoSystemBackground);

    setResizeMode(QQuickView::SizeRootObjectToView);

    KDeclarative kdeclarative;
    kdeclarative.setDeclarativeEngine(engine());
    kdeclarative.initialize();
    //binds things like kconfig and icons
    kdeclarative.setupBindings();

    Plasma::PackageStructure::Ptr structure = Plasma::PackageStructure::load("Plasma/Generic");
    m_package = new Plasma::Package(QString(), "org.kde.active.settings", structure);

    if (!module.isEmpty()) {
        rootContext()->setContextProperty("startModule", module);
    }

    const QString qmlFile = m_package->filePath("mainscript");
    setSource(QUrl::fromLocalFile(m_package->filePath("mainscript")));
    show();

    onStatusChanged(status());

    //connect(engine(), SIGNAL(signalHandlerException(QScriptValue)), this, SLOT(exception()));
    connect(this, SIGNAL(statusChanged(QQuickView::Status)),
            this, SLOT(onStatusChanged(QQuickView::Status)));
}

View::~View()
{
    delete m_package;
}

void View::updateStatus()
{
    onStatusChanged(status());
}

void View::onStatusChanged(QQuickView::Status status)
{
    //kDebug() << "onStatusChanged";
    if (status == QQuickView::Ready) {
        if (!m_settingsRoot) {
            m_settingsRoot = rootObject()->findChild<QQuickItem*>("settingsRoot");
            if (!m_settingsRoot) {
                kError() << "settingsRoot component not found. :(";
            }
        }
    } else if (status == QQuickView::Error) {
        foreach (const QQmlError &e, errors()) {
            kWarning() << "error in QML: " << e.toString() << e.description();
        }
    } else if (status == QQuickView::Loading) {
        //kDebug() << "Loading.";
    }
}

#include "view.moc"
