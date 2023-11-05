// SPDX-FileCopyrightText: 2022-2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "screenrotationplugin.h"

#include <QQmlContext>
#include <QQuickItem>

#include "screenrotationutil.h"

void ScreenRotationPlugin::registerTypes(const char *uri)
{
    Q_ASSERT(QLatin1String(uri) == QLatin1String("org.kde.plasma.quicksetting.screenrotation"));

    qmlRegisterSingletonType<ScreenRotationUtil>(uri, 1, 0, "ScreenRotationUtil", [](QQmlEngine *, QJSEngine *) {
        return new ScreenRotationUtil;
    });
}

//#include "moc_screenrotationplugin.cpp"
