// SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include <Plasma/Containment>

#include <applicationlistmodel.h>

class HomeScreen : public Plasma::Containment
{
    Q_OBJECT

public:
    HomeScreen(QObject *parent, const KPluginMetaData &data, const QVariantList &args);
    ~HomeScreen() override;
};
