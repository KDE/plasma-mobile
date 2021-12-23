// SPDX-FileCopyrightText: 2021 Tobias Fella <fella@posteo.de>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "mmqmlplugin.h"

#include <QQmlContext>
#include <QQmlEngine>

#include "signalindicator.h"

void MmQmlPlugin::registerTypes(const char *)
{
    qmlRegisterSingletonType<SignalIndicator>("org.kde.plasma.mm", 1, 0, "SignalIndicator", [](QQmlEngine *, QJSEngine *) -> QObject * {
        return new SignalIndicator();
    });
}
