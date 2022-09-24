// SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include <Plasma/Containment>

#include <applicationlistmodel.h>

class HomeScreen : public Plasma::Containment
{
    Q_OBJECT
    Q_PROPERTY(bool showingDesktop READ showingDesktop WRITE setShowingDesktop NOTIFY showingDesktopChanged)

public:
    HomeScreen(QObject *parent, const KPluginMetaData &data, const QVariantList &args);
    ~HomeScreen() override;

    bool showingDesktop() const;
    void setShowingDesktop(bool showingDesktop);

Q_SIGNALS:
    void showingDesktopChanged(bool showingDesktop);
};
