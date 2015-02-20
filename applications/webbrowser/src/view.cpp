/***************************************************************************
 *                                                                         *
 *   Copyright 2014-2015 Sebastian Kügler <sebas@kde.org>                  *
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
#include "browsermanager.h"

#include <QDebug>
#include <QtQml>
#include <QQmlContext>
#include <QQmlEngine>
#include <QQuickItem>

#include <QtWebEngine/qtwebengineglobal.h>

#include <Plasma/Package>
#include <Plasma/PluginLoader>

#include <KDeclarative/KDeclarative>
#include <KLocalizedString>

using namespace AngelFish;

View::View(const QString &url, QWindow *parent)
    : QQuickView(parent),
    m_browserRootItem(0)
{
    setResizeMode(QQuickView::SizeRootObjectToView);
    QQuickWindow::setDefaultAlphaBuffer(true);

    QtWebEngine::initialize();

    KDeclarative::KDeclarative kdeclarative;
    kdeclarative.setDeclarativeEngine(engine());
    kdeclarative.initialize();
    kdeclarative.setupBindings();

    BrowserManager *browserManager = new BrowserManager(rootContext());
    rootContext()->setContextProperty("browserManager", browserManager);
    qmlRegisterUncreatableType<BrowserManager>("org.kde.plasma.satellite.angelfish", 1, 0, "BrowserManager", "");

    qmlRegisterType<QAbstractListModel>();

    m_package = Plasma::PluginLoader::self()->loadPackage("Plasma/Generic");
    m_package.setPath("org.kde.plasma.satellite.angelfish");

    if (!m_package.isValid() || !m_package.metadata().isValid()) {
        qWarning() << "Could not load package org.kde.plasma.satellite.angelfish:" << m_package.path();
        return;
    }

    setIcon(QIcon::fromTheme(m_package.metadata().icon()));
    setTitle(m_package.metadata().name());

    const QString qmlFile = m_package.filePath("mainscript");
    setSource(QUrl::fromLocalFile(m_package.filePath("mainscript")));
    show();

    QMetaObject::invokeMethod(rootObject(), "load", Q_ARG(QVariant, BrowserManager::urlFromUserInput(url)));

}

View::~View()
{
}
