// SPDX-FileCopyrightText: 2023 by Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "wifiplugin.h"

#include <QQmlContext>
#include <QQuickItem>

#include "wifiutil.h"

void WiFiPlugin::registerTypes(const char *uri)
{
    Q_ASSERT(QLatin1String(uri) == QLatin1String("org.kde.plasma.mobileinitialstart.wifi"));

    qmlRegisterSingletonType<WiFiUtil>(uri, 1, 0, "WiFiUtil", [](QQmlEngine *, QJSEngine *) {
        return new WiFiUtil;
    });
}
