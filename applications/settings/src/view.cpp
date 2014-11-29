/***************************************************************************
 *                                                                         *
 *   Copyright 2011-2014 Sebastian Kügler <sebas@kde.org>                  *
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

#include <QDebug>
#include <QQmlContext>
#include <QQmlEngine>
#include <QQuickItem>

#include <Plasma/Package>
#include <Plasma/PluginLoader>

#include <KDeclarative/KDeclarative>
#include <KLocalizedString>


View::View(const QString &module, QWindow *parent)
    : QQuickView(parent),
    m_settingsRoot(0)
{
    setResizeMode(QQuickView::SizeRootObjectToView);
    QQuickWindow::setDefaultAlphaBuffer(true);

    setIcon(QIcon::fromTheme("preferences-desktop"));
    setTitle(i18n("Active Settings"));

    KDeclarative::KDeclarative kdeclarative;
    kdeclarative.setDeclarativeEngine(engine());
    kdeclarative.initialize();
    //binds things like kconfig and icons
    kdeclarative.setupBindings();

    m_package = Plasma::PluginLoader::self()->loadPackage("Plasma/Generic");
    m_package.setPath("org.kde.active.settings");

    if (!module.isEmpty()) {
        rootContext()->setContextProperty("startModule", module);
    }

    const QString qmlFile = m_package.filePath("mainscript");
    //qDebug() << "mainscript: " << QUrl::fromLocalFile(m_package.filePath("mainscript"));
    setSource(QUrl::fromLocalFile(m_package.filePath("mainscript")));
    show();

    onStatusChanged(status());

    //connect(engine(), SIGNAL(signalHandlerException(QScriptValue)), this, SLOT(exception()));
    connect(this, SIGNAL(statusChanged(QQuickView::Status)),
            this, SLOT(onStatusChanged(QQuickView::Status)));
}

View::~View()
{
}

void View::updateStatus()
{
    onStatusChanged(status());
}

void View::onStatusChanged(QQuickView::Status status)
{
    //qDebug() << "onStatusChanged";
    if (status == QQuickView::Ready) {
        if (!m_settingsRoot) {
            m_settingsRoot = rootObject()->findChild<QQuickItem*>("settingsRoot");
            if (!m_settingsRoot) {
                qWarning() << "settingsRoot component not found. :(";
            }
        }
    } else if (status == QQuickView::Error) {
        foreach (const QQmlError &e, errors()) {
            qWarning() << "error in QML: " << e.toString() << e.description();
        }
    } else if (status == QQuickView::Loading) {
        //qDebug() << "Loading.";
    }
}

