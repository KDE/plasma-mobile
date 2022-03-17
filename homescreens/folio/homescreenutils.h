/*
    SPDX-FileCopyrightText: 2021 Marco Martin <mart@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
 */

#pragma once

#include <QObject>

class QQuickItem;
class FavoritesModel;

class HomeScreenUtils : public QObject
{
    Q_OBJECT

public:
    HomeScreenUtils(QObject *parent = 0);
    ~HomeScreenUtils() override;

    Q_INVOKABLE void stackBefore(QQuickItem *item1, QQuickItem *item2);
    Q_INVOKABLE void stackAfter(QQuickItem *item1, QQuickItem *item2);

protected:
    // void configChanged() override;

private:
    bool m_showAllApps = false;
};
