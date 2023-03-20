// SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "mobileshellstateplugin.h"
#include "shelldbusclient.h"
#include "shelldbusobject.h"

#include <QQmlContext>
#include <QQuickItem>

QUrl resolvePath(std::string str)
{
    return QUrl("qrc:/org/kde/plasma/private/mobileshell/state/qml/" + QString::fromStdString(str));
}

void MobileShellStatePlugin::registerTypes(const char *uri)
{
    Q_ASSERT(QLatin1String(uri) == QLatin1String("org.kde.plasma.private.mobileshell.state"));

    qmlRegisterSingletonType<ShellDBusClient>(uri, 1, 0, "ShellDBusClient", [](QQmlEngine *, QJSEngine *) -> QObject * {
        return ShellDBusClient::self();
    });
    qmlRegisterSingletonType<ShellDBusObject>(uri, 1, 0, "ShellDBusObject", [](QQmlEngine *, QJSEngine *) -> QObject * {
        return ShellDBusObject::self();
    });
}
