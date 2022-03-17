/*
 * SPDX-FileCopyrightText: 2022 by Devin Lin <devin@kde.org>
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

#include "screenshotplugin.h"

#include <QQmlContext>
#include <QQuickItem>

#include "screenshotutil.h"

void ScreenShotPlugin::registerTypes(const char *uri)
{
    Q_ASSERT(QLatin1String(uri) == QLatin1String("org.kde.plasma.quicksetting.screenshot"));

    qmlRegisterSingletonType<ScreenShotUtil>(uri, 1, 0, "ScreenShotUtil", [](QQmlEngine *, QJSEngine *) {
        return new ScreenShotUtil;
    });
}

//#include "moc_screenshotplugin.cpp"
