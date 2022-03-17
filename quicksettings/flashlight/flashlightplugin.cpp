/*
 * SPDX-FileCopyrightText: 2022 by Devin Lin <devin@kde.org>
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

#include "flashlightplugin.h"

#include <QQmlContext>
#include <QQuickItem>

#include "flashlightutil.h"

void FlashlightPlugin::registerTypes(const char *uri)
{
    Q_ASSERT(QLatin1String(uri) == QLatin1String("org.kde.plasma.quicksetting.flashlight"));

    qmlRegisterSingletonType<FlashlightUtil>(uri, 1, 0, "FlashlightUtil", [](QQmlEngine *, QJSEngine *) {
        return new FlashlightUtil;
    });
}

//#include "moc_flashlightplugin.cpp"
