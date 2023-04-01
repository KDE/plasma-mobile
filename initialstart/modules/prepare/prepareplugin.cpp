// SPDX-FileCopyrightText: 2023 by Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "prepareplugin.h"

#include <QQmlContext>
#include <QQuickItem>

#include "prepareutil.h"

void PreparePlugin::registerTypes(const char *uri)
{
    Q_ASSERT(QLatin1String(uri) == QLatin1String("org.kde.plasma.mobileinitialstart.prepare"));

    qmlRegisterSingletonType<PrepareUtil>(uri, 1, 0, "PrepareUtil", [](QQmlEngine *, QJSEngine *) {
        return new PrepareUtil;
    });
}
