// SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>
// SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
//
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include <Plasma/Containment>

class PhonePanel : public Plasma::Containment
{
    Q_OBJECT

public:
    PhonePanel(QObject *parent, const KPluginMetaData &data, const QVariantList &args);
    ~PhonePanel() override;
};
