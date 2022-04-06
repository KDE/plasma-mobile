/*
    SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
 */

#pragma once

#include <Plasma/Containment>

class HomeScreen : public Plasma::Containment
{
    Q_OBJECT
    Q_PROPERTY(bool showingDesktop READ showingDesktop WRITE setShowingDesktop NOTIFY showingDesktopChanged)

public:
    HomeScreen(QObject *parent, const QVariantList &args);
    ~HomeScreen() override;

    void configChanged() override;

    bool showingDesktop() const;
    void setShowingDesktop(bool showingDesktop);

Q_SIGNALS:
    void showingDesktopChanged(bool showingDesktop);

private:
    bool m_showAllApps = false;
};
