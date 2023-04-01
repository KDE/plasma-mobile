// SPDX-FileCopyrightText: 2023 by Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "cellularplugin.h"

#include <QQmlContext>
#include <QQuickItem>

void CellularPlugin::registerTypes(const char *uri)
{
    Q_ASSERT(QLatin1String(uri) == QLatin1String("org.kde.plasma.mobileinitialstart.cellular"));
}
