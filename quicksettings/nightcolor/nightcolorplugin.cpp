/*
 * SPDX-FileCopyrightText: 2022 by Devin Lin <devin@kde.org>
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

#include "nightcolorplugin.h"

#include <QQmlContext>
#include <QQuickItem>

#include "nightcolorutil.h"

void NightColorPlugin::registerTypes(const char *uri)
{
    Q_ASSERT(QLatin1String(uri) == QLatin1String("org.kde.plasma.quicksetting.nightcolor"));

    qmlRegisterSingletonType<NightColorUtil>(uri, 1, 0, "NightColorUtil", [](QQmlEngine *, QJSEngine *) {
        return new NightColorUtil;
    });
}

//#include "moc_nightcolorplugin.cpp"
