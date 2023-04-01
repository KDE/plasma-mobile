// SPDX-FileCopyrightText: 2023 by Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "timeplugin.h"

#include <QQmlContext>
#include <QQuickItem>

#include "timeutil.h"

void TimePlugin::registerTypes(const char *uri)
{
    Q_ASSERT(QLatin1String(uri) == QLatin1String("org.kde.plasma.mobileinitialstart.time"));

    qmlRegisterSingletonType<TimeUtil>(uri, 1, 0, "TimeUtil", [](QQmlEngine *, QJSEngine *) {
        return new TimeUtil;
    });
}

// #include "moc_flashlightplugin.cpp"
