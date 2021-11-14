/*
 *  SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

#include <QQmlContext>
#include <QQuickItem>

#include "axisvelocitycalculator.h"
#include "direction.h"
#include "gesturesplugin.h"
#include "ucswipearea_p.h"

void GesturesPlugin::registerTypes(const char *uri)
{
    Q_ASSERT(QLatin1String(uri) == QLatin1String("org.kde.plasma.private.gestures"));

    qmlRegisterType<AxisVelocityCalculator>(uri, 0, 1, "AxisVelocityCalculator");
    qmlRegisterType<UCSwipeArea>(uri, 0, 1, "SwipeArea");

    qmlRegisterSingletonType<Direction>(uri, 0, 1, "Direction", [](QQmlEngine *, QJSEngine *) {
        return new Direction{};
    });

    // TODO
    QLoggingCategory::setFilterRules(QStringLiteral("foo.debug = true"));
}
