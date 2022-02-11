/*
 * SPDX-FileCopyrightText: 2022 by Devin Lin <devin@kde.org>
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

#include "powermenuplugin.h"

#include <QQmlContext>
#include <QQuickItem>

#include "powermenuutil.h"

void PowerMenuPlugin::registerTypes(const char *uri)
{
    Q_ASSERT(QLatin1String(uri) == QLatin1String("org.kde.plasma.quicksetting.powermenu"));

    qmlRegisterSingletonType<PowerMenuUtil>(uri, 1, 0, "PowerMenuUtil", [](QQmlEngine *, QJSEngine *) {
        return new PowerMenuUtil;
    });
}

//#include "moc_powermenuplugin.cpp"
