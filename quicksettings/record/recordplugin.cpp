/*
 * SPDX-FileCopyrightText: 2022 by Devin Lin <devin@kde.org>
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

#include "recordplugin.h"

#include <QQmlContext>
#include <QQuickItem>

#include "recordutil.h"

void RecordPlugin::registerTypes(const char *uri)
{
    Q_ASSERT(QLatin1String(uri) == QLatin1String("org.kde.plasma.quicksetting.record"));

    qmlRegisterSingletonType<RecordUtil>(uri, 1, 0, "RecordUtil", [](QQmlEngine *, QJSEngine *) {
        return new RecordUtil;
    });
}

//#include "moc_screenshotplugin.cpp"
