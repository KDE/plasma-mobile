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

#include "taskswitcher/displaysmodel.h"

#include "quicksettings/paginatemodel.h"
#include "quicksettings/quicksetting.h"
#include "quicksettings/quicksettingsmodel.h"

#include "mobileshellsettings.h"
#include "shellutil.h"
#include "windowutil.h"

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

    qmlRegisterSingletonType<MobileShellSettings>(uri, 1, 0, "MobileShellSettings", [](QQmlEngine *, QJSEngine *) -> QObject * {
        return MobileShellSettings::self();
    });

    qmlRegisterType<QuickSetting>(uri, 1, 0, "QuickSetting");
    qmlRegisterType<QuickSettingsModel>(uri, 1, 0, "QuickSettingsModel");
    qmlRegisterType<PaginateModel>(uri, 1, 0, "PaginateModel");
    qmlRegisterType<SavedQuickSettings>(uri, 1, 0, "SavedQuickSettings");
    qmlRegisterType<SavedQuickSettingsModel>(uri, 1, 0, "SavedQuickSettingsModel");
    qmlRegisterSingletonType<WindowUtil>(uri, 1, 0, "WindowUtil", [](QQmlEngine *, QJSEngine *) -> QObject * {
        return WindowUtil::instance();
    });

    // components
    qmlRegisterType<Direction>(uri, 1, 0, "Direction");

    // notifications
    qmlRegisterType<NotificationThumbnailer>(uri, 1, 0, "NotificationThumbnailer");
    qmlRegisterType<NotificationFileMenu>(uri, 1, 0, "NotificationFileMenu");

    // taskswitcher
    qmlRegisterType<DisplaysModel>(uri, 1, 0, "DisplaysModel");

    // qml modules

    // /actiondrawer
    qmlRegisterType(resolvePath("actiondrawer/ActionDrawer.qml"), uri, 1, 0, "ActionDrawer");
    qmlRegisterType(resolvePath("actiondrawer/ActionDrawerOpenSurface.qml"), uri, 1, 0, "ActionDrawerOpenSurface");
    qmlRegisterType(resolvePath("actiondrawer/ActionDrawerWindow.qml"), uri, 1, 0, "ActionDrawerWindow");

    // /components
    qmlRegisterType(resolvePath("components/BaseItem.qml"), uri, 1, 0, "BaseItem");
    qmlRegisterType(resolvePath("components/ExtendedAbstractButton.qml"), uri, 1, 0, "ExtendedAbstractButton");
    qmlRegisterType(resolvePath("components/Flickable.qml"), uri, 1, 0, "Flickable");
    qmlRegisterType(resolvePath("components/GridView.qml"), uri, 1, 0, "GridView");
    qmlRegisterType(resolvePath("components/ListView.qml"), uri, 1, 0, "ListView");
    qmlRegisterSingletonType(resolvePath("components/Haptics.qml"), uri, 1, 0, "Haptics");
    qmlRegisterType(resolvePath("components/StartupFeedback.qml"), uri, 1, 0, "StartupFeedback");
    qmlRegisterType(resolvePath("components/VelocityCalculator.qml"), uri, 1, 0, "VelocityCalculator");

    // /dataproviders
    qmlRegisterSingletonType(resolvePath("dataproviders/BatteryProvider.qml"), uri, 1, 0, "BatteryProvider");
    qmlRegisterSingletonType(resolvePath("dataproviders/BluetoothProvider.qml"), uri, 1, 0, "BluetoothProvider");
    qmlRegisterSingletonType(resolvePath("dataproviders/SignalStrengthProvider.qml"), uri, 1, 0, "SignalStrengthProvider");
    qmlRegisterSingletonType(resolvePath("dataproviders/VolumeProvider.qml"), uri, 1, 0, "VolumeProvider");
    qmlRegisterSingletonType(resolvePath("dataproviders/WifiProvider.qml"), uri, 1, 0, "WifiProvider");

    // /homescreen
    qmlRegisterType(resolvePath("homescreen/HomeScreen.qml"), uri, 1, 0, "HomeScreen");

    // /navigationpanel
    qmlRegisterType(resolvePath("navigationpanel/NavigationGestureArea.qml"), uri, 1, 0, "NavigationGestureArea");
    qmlRegisterType(resolvePath("navigationpanel/NavigationPanel.qml"), uri, 1, 0, "NavigationPanel");
    qmlRegisterType(resolvePath("navigationpanel/NavigationPanelAction.qml"), uri, 1, 0, "NavigationPanelAction");

    // /statusbar
    qmlRegisterType(resolvePath("statusbar/StatusBar.qml"), uri, 1, 0, "StatusBar");

    // /taskswitcher
    qmlRegisterType(resolvePath("taskswitcher/TaskSwitcher.qml"), uri, 1, 0, "TaskSwitcher");

    // /widgets
    qmlRegisterType(resolvePath("widgets/dialercontrols/DialerControlsWidget.qml"), uri, 1, 0, "DialerControlsWidget");
    qmlRegisterType(resolvePath("widgets/krunner/KRunnerWidget.qml"), uri, 1, 0, "KRunnerWidget");
    qmlRegisterType(resolvePath("widgets/mediacontrols/MediaControlsWidget.qml"), uri, 1, 0, "MediaControlsWidget");
    qmlRegisterType(resolvePath("widgets/notifications/NotificationsWidget.qml"), uri, 1, 0, "NotificationsWidget");
    qmlRegisterType(resolvePath("widgets/notifications/NotificationsModelType.qml"), uri, 1, 0, "NotificationsModelType");

    // /
    qmlRegisterSingletonType(resolvePath("HomeScreenControls.qml"), uri, 1, 0, "HomeScreenControls");
    qmlRegisterSingletonType(resolvePath("Shell.qml"), uri, 1, 0, "Shell");
    qmlRegisterSingletonType(resolvePath("TaskPanelControls.qml"), uri, 1, 0, "TaskPanelControls");
    qmlRegisterSingletonType(resolvePath("TopPanelControls.qml"), uri, 1, 0, "TopPanelControls");
}
