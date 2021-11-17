/*
 *  SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

#include <QQmlContext>
#include <QQuickItem>

#include "gesturesplugin.h"
#include "swipearea.h"

void GesturesPlugin::registerTypes(const char *uri)
{
    Q_ASSERT(QLatin1String(uri) == QLatin1String("org.kde.plasma.private.gestures"));

    qmlRegisterType<SwipeArea>(uri, 1, 0, "SwipeArea");
}
