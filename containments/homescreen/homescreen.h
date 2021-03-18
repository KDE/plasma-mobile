/*
    SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
 */

#ifndef HOMESCREEN_H
#define HOMESCREEN_H

#include <Plasma/Containment>

class QQuickItem;
class ApplicationListModel;
class FavoritesModel;

class HomeScreen : public Plasma::Containment
{
    Q_OBJECT

public:
    HomeScreen(QObject *parent, const QVariantList &args);
    ~HomeScreen() override;

    void configChanged() override;


    Q_INVOKABLE void stackBefore(QQuickItem *item1, QQuickItem *item2);
    Q_INVOKABLE void stackAfter(QQuickItem *item1, QQuickItem *item2);

protected:
    // void configChanged() override;

private:
    bool m_showAllApps = false;
};

#endif
