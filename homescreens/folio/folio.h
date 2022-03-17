/*
    SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
 */

#pragma once

#include <Plasma/Containment>

class Folio : public Plasma::Containment
{
    Q_OBJECT

public:
    Folio(QObject *parent, KPluginMetaData pluginMetaData, const QVariantList &args);
    ~Folio() override;

    void configChanged() override;
};
