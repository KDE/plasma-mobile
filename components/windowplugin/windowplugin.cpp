// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "windowplugin.h"
#include "windowutil.h"

#include <QQmlContext>
#include <QQuickItem>

void WindowPlugin::registerTypes(const char *uri)
{
    Q_ASSERT(QLatin1String(uri) == QLatin1String("org.kde.plasma.private.mobileshell.windowplugin"));

    qmlRegisterSingletonType<WindowUtil>(uri, 1, 0, "WindowUtil", [](QQmlEngine *, QJSEngine *) -> QObject * {
        return WindowUtil::instance();
    });
}
