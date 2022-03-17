// SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

#pragma once

#include <QObject>

#include <Plasma/Containment>

#include "mobileshell_export.h"

namespace MobileShell
{

class MOBILESHELL_EXPORT HomeScreen : public Plasma::Containment
{
    Q_OBJECT

public:
    HomeScreen(QObject *parent = nullptr, const KPluginMetaData &data = {}, const QVariantList &args = {});
};

} // namespace MobileShell
