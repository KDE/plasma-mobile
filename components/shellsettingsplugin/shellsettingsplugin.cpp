// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "shellsettingsplugin.h"
#include "mobileshellsettings.h"

#include <QQmlContext>
#include <QQuickItem>

void ShellSettingsPlugin::registerTypes(const char *uri)
{
    Q_ASSERT(QLatin1String(uri) == QLatin1String("org.kde.plasma.private.mobileshell.shellsettingsplugin"));

    qmlRegisterSingletonType<MobileShellSettings>(uri, 1, 0, "Settings", [](QQmlEngine *, QJSEngine *) -> QObject * {
        return MobileShellSettings::self();
    });
}
