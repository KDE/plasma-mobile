// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "initialstartplugin.h"
#include "initialstartutil.h"

#include <QQmlContext>
#include <QQuickItem>

void InitialStartPlugin::registerTypes(const char *uri)
{
    Q_ASSERT(QLatin1String(uri) == QLatin1String("org.kde.plasma.mobileinitialstart.initialstart"));

    qmlRegisterSingletonType<InitialStartUtil>(uri, 1, 0, "InitialStartUtil", [](QQmlEngine *, QJSEngine *) {
        return new InitialStartUtil;
    });
}
