// SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include <Plasma/Containment>

#include "halcyonsettings.h"
#include "pinnedmodel.h"

class HomeScreen : public Plasma::Containment
{
    Q_OBJECT
    Q_PROPERTY(HalcyonSettings *settings READ settings CONSTANT)
    Q_PROPERTY(PinnedModel *pinnedModel READ pinnedModel CONSTANT)

public:
    HomeScreen(QObject *parent, const KPluginMetaData &data, const QVariantList &args);
    ~HomeScreen() override;

    HalcyonSettings *settings() const;
    PinnedModel *pinnedModel() const;

Q_SIGNALS:
    void showingDesktopChanged(bool showingDesktop);

private:
    HalcyonSettings *m_settings{nullptr};
    PinnedModel *m_pinnedModel{nullptr};
};
