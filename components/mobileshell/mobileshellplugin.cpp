/*
 *  SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

#include "mobileshellplugin.h"

#include <QQmlContext>
#include <QQuickItem>

#include "components/direction.h"

#include "notifications/notificationfilemenu.h"
#include "notifications/notificationthumbnailer.h"

#include "shellutil.h"

QUrl resolvePath(std::string str)
{
    return QUrl("qrc:/org/kde/plasma/private/mobileshell/qml/" + QString::fromStdString(str));
}

void MobileShellPlugin::registerTypes(const char *uri)
{
    Q_ASSERT(QLatin1String(uri) == QLatin1String("org.kde.plasma.private.mobileshell"));

    qmlRegisterSingletonType<ShellUtil>(uri, 1, 0, "ShellUtil", [](QQmlEngine *, QJSEngine *) -> QObject * {
        return ShellUtil::instance();
    });

    // components
    qmlRegisterType<Direction>(uri, 1, 0, "Direction");

    // notifications
    qmlRegisterType<NotificationThumbnailer>(uri, 1, 0, "NotificationThumbnailer");
    qmlRegisterType<NotificationFileMenu>(uri, 1, 0, "NotificationFileMenu");

    // qml modules

    // /actiondrawer
    qmlRegisterType(resolvePath("actiondrawer/ActionDrawer.qml"), uri, 1, 0, "ActionDrawer");
    qmlRegisterType(resolvePath("actiondrawer/ActionDrawerOpenSurface.qml"), uri, 1, 0, "ActionDrawerOpenSurface");
    qmlRegisterType(resolvePath("actiondrawer/ActionDrawerWindow.qml"), uri, 1, 0, "ActionDrawerWindow");

    // /components
    qmlRegisterSingletonType(resolvePath("components/AppLaunch.qml"), uri, 1, 0, "AppLaunch");
    qmlRegisterType(resolvePath("components/BaseItem.qml"), uri, 1, 0, "BaseItem");
    qmlRegisterSingletonType(resolvePath("components/Constants.qml"), uri, 1, 0, "Constants");
    qmlRegisterType(resolvePath("components/ExtendedAbstractButton.qml"), uri, 1, 0, "ExtendedAbstractButton");
    qmlRegisterType(resolvePath("components/Flickable.qml"), uri, 1, 0, "Flickable");
    qmlRegisterType(resolvePath("components/GridView.qml"), uri, 1, 0, "GridView");
    qmlRegisterType(resolvePath("components/HapticsEffectLoader.qml"), uri, 1, 0, "HapticsEffectLoader");
    qmlRegisterType(resolvePath("components/ListView.qml"), uri, 1, 0, "ListView");
    qmlRegisterType(resolvePath("components/PopupMenu.qml"), uri, 1, 0, "PopupMenu");
    qmlRegisterType(resolvePath("components/StartupFeedback.qml"), uri, 1, 0, "StartupFeedback");
    qmlRegisterType(resolvePath("components/VelocityCalculator.qml"), uri, 1, 0, "VelocityCalculator");

    // /dataproviders
    qmlRegisterType(resolvePath("dataproviders/AudioInfo.qml"), uri, 1, 0, "AudioInfo");
    qmlRegisterType(resolvePath("dataproviders/BatteryInfo.qml"), uri, 1, 0, "BatteryInfo");
    qmlRegisterType(resolvePath("dataproviders/BluetoothInfo.qml"), uri, 1, 0, "BluetoothInfo");
    qmlRegisterType(resolvePath("dataproviders/SignalStrengthInfo.qml"), uri, 1, 0, "SignalStrengthInfo");

    // /homescreen
    qmlRegisterType(resolvePath("homescreen/HomeScreen.qml"), uri, 1, 0, "HomeScreen");

    // /navigationpanel
    qmlRegisterType(resolvePath("navigationpanel/NavigationPanel.qml"), uri, 1, 0, "NavigationPanel");
    qmlRegisterType(resolvePath("navigationpanel/NavigationPanelAction.qml"), uri, 1, 0, "NavigationPanelAction");

    // /statusbar
    qmlRegisterType(resolvePath("statusbar/StatusBar.qml"), uri, 1, 0, "StatusBar");

    // /volumeosd
    qmlRegisterType(resolvePath("volumeosd/VolumeOSD.qml"), uri, 1, 0, "VolumeOSD");
    qmlRegisterType(resolvePath("volumeosd/VolumeOSDProvider.qml"), uri, 1, 0, "VolumeOSDProvider");
    qmlRegisterSingletonType(resolvePath("volumeosd/VolumeOSDProviderLoader.qml"), uri, 1, 0, "VolumeOSDProviderLoader");

    // /widgets
    qmlRegisterType(resolvePath("widgets/krunner/KRunnerWidget.qml"), uri, 1, 0, "KRunnerWidget");
    qmlRegisterType(resolvePath("widgets/mediacontrols/MediaControlsWidget.qml"), uri, 1, 0, "MediaControlsWidget");
    qmlRegisterType(resolvePath("widgets/notifications/NotificationsWidget.qml"), uri, 1, 0, "NotificationsWidget");
    qmlRegisterType(resolvePath("widgets/notifications/NotificationsModelType.qml"), uri, 1, 0, "NotificationsModelType");
}
