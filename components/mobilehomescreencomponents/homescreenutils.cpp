/*
    SPDX-FileCopyrightText: 2021 Marco Martin <mart@kde.org>
    SPDX-License-Identifier: GPL-2.0-or-later
 */

#include "homescreenutils.h"
#include "applicationlistmodel.h"
#include "favoritesmodel.h"

#include <QtQml>
#include <QDebug>
#include <QQuickItem>

HomeScreenUtils::HomeScreenUtils(QObject *parent)
    : QObject(parent)
{

}

HomeScreenUtils::~HomeScreenUtils() = default;

ApplicationListModel *HomeScreenUtils::applicationListModel()
{
    if (!m_applicationListModel) {
        if (m_showAllApps) {
            m_applicationListModel = new ApplicationListModel(this);
        } else {
            m_applicationListModel = new FavoritesModel(this);
        }
      //  m_applicationListModel->setApplet(this);
        m_applicationListModel->loadApplications();
    }
    return m_applicationListModel;
}

void HomeScreenUtils::stackBefore(QQuickItem *item1, QQuickItem *item2)
{
    if (!item1 || !item2 || item1 == item2 || item1->parentItem() != item2->parentItem()) {
        return;
    }

    item1->stackBefore(item2);
}

void HomeScreenUtils::stackAfter(QQuickItem *item1, QQuickItem *item2)
{
    if (!item1 || !item2 || item1 == item2 || item1->parentItem() != item2->parentItem()) {
        return;
    }

    item1->stackAfter(item2);
}


#include "moc_homescreenutils.cpp"
