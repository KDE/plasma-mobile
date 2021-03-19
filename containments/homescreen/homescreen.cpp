/*
    SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>
    SPDX-License-Identifier: GPL-2.0-or-later
 */

#include "homescreen.h"
#include "applicationlistmodel.h"
#include "favoritesmodel.h"

#include <QDebug>
#include <QQuickItem>
#include <QtQml>

HomeScreen::HomeScreen(QObject *parent, const QVariantList &args)
    : Plasma::Containment(parent, args)
{
    qmlRegisterType<ApplicationListModel>("org.kde.phone.homescreen", 1, 0, "ApplicationListModel");
    qmlRegisterType<FavoritesModel>("org.kde.phone.homescreen", 1, 0, "FavoritesModel");

    setHasConfigurationInterface(true);
}

HomeScreen::~HomeScreen() = default;

void HomeScreen::configChanged()
{
    Plasma::Containment::configChanged();
    if (m_applicationListModel) {
        m_applicationListModel->loadSettings();
    }
}

ApplicationListModel *HomeScreen::applicationListModel()
{
    if (!m_applicationListModel) {
        if (m_showAllApps) {
            m_applicationListModel = new ApplicationListModel(this);
        } else {
            m_applicationListModel = new FavoritesModel(this);
        }
        m_applicationListModel->setApplet(this);
        m_applicationListModel->loadApplications();
    }
    return m_applicationListModel;
}

void HomeScreen::stackBefore(QQuickItem *item1, QQuickItem *item2)
{
    if (!item1 || !item2 || item1 == item2 || item1->parentItem() != item2->parentItem()) {
        return;
    }

    item1->stackBefore(item2);
}

void HomeScreen::stackAfter(QQuickItem *item1, QQuickItem *item2)
{
    if (!item1 || !item2 || item1 == item2 || item1->parentItem() != item2->parentItem()) {
        return;
    }

    item1->stackAfter(item2);
}

K_EXPORT_PLASMA_APPLET_WITH_JSON(homescreen, HomeScreen, "metadata.json")

#include "homescreen.moc"
