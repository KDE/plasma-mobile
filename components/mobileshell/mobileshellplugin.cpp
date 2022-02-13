/*
 *  SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

#include "mobileshellplugin.h"

#include <QQmlContext>
#include <QQuickItem>

#include "displaysmodel.h"
#include "mobileshellsettings.h"
#include "notifications/notificationfilemenu.h"
#include "notifications/notificationthumbnailer.h"
#include "quicksettingsmodel.h"
#include "shellutil.h"
#include "virtualkeyboardinterface.h"
#include "vkbdinterface.h"

void MobileShellPlugin::registerTypes(const char *uri)
{
    Q_ASSERT(QLatin1String(uri) == QLatin1String("org.kde.plasma.private.mobileshell"));

    qmlRegisterSingletonType<ShellUtil>(uri, 1, 0, "ShellUtil", [](QQmlEngine *, QJSEngine *) -> QObject * {
        return ShellUtil::instance();
    });

    qmlRegisterSingletonType<MobileShellSettings>(uri, 1, 0, "MobileShellSettings", [](QQmlEngine *, QJSEngine *) -> QObject * {
        return MobileShellSettings::self();
    });

    qmlRegisterType<QuickSetting>(uri, 1, 0, "QuickSetting");
    qmlRegisterType<QuickSettingsModel>(uri, 1, 0, "QuickSettingsModel");

    qmlRegisterType<DisplaysModel>(uri, 1, 0, "DisplaysModel");
    qmlRegisterSingletonType<OrgKdeKwinVirtualKeyboardInterface>(uri, 1, 0, "KWinVirtualKeyboard", [](QQmlEngine *, QJSEngine *) -> QObject * {
        return new KwinVirtualKeyboardInterface;
    });

    // notifications
    qmlRegisterType<NotificationThumbnailer>(uri, 1, 0, "NotificationThumbnailer");
    qmlRegisterType<NotificationFileMenu>(uri, 1, 0, "NotificationFileMenu");
}
