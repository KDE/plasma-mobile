// SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>
// SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include <Plasma/Containment>
#include <QSortFilterProxyModel>

class HomeScreen : public Plasma::Containment
{
    Q_OBJECT

public:
    HomeScreen(QObject *parent, const KPluginMetaData &data, const QVariantList &args);
    ~HomeScreen() override;

    void configChanged() override;

Q_SIGNALS:
    void showingDesktopChanged(bool showingDesktop);

private Q_SLOTS:
    void onAppletAdded(Plasma::Applet *applet, const QRectF &geometryHint);
    void onAppletAboutToBeRemoved(Plasma::Applet *applet);
};
