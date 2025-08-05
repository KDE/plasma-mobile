// SPDX-FileCopyrightText: 2025 Sebastian Kügler <sebas@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "kscreenosdplugin.h"

#include <QQmlContext>
#include <QQuickItem>

#include "kscreenosdutil.h"

void KScreenOSDPlugin::registerTypes(const char *uri)
{
    Q_ASSERT(QLatin1String(uri) == QLatin1String("org.kde.plasma.quicksetting.kscreenosd"));

    qmlRegisterSingletonType<KScreenOSDUtil>(uri, 1, 0, "KScreenOSDUtil", [](QQmlEngine *, QJSEngine *) {
        return new KScreenOSDUtil;
    });
}

//#include "moc_screenrotationplugin.cpp"
