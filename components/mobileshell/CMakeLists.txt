# SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
# SPDX-License-Identifier: GPL-2.0-or-later

ecm_add_qml_module(mobileshellplugin URI org.kde.plasma.private.mobileshell GENERATE_PLUGIN_SOURCE DEPENDENCIES QtQuick)

set(mobileshellplugin_SRCS
    shellutil.cpp
    components/direction.cpp
    components/direction.h
    components/swipearea.cpp
    notifications/notificationthumbnailer.cpp
    notifications/notificationfilemenu.cpp
    notifications/notificationfileinfo.cpp
    masklayer/masklayer.cpp
    masklayer/maskmanager.cpp
)
target_include_directories(mobileshellplugin PRIVATE components)
target_include_directories(mobileshellplugin PRIVATE notifications)
target_include_directories(mobileshellplugin PRIVATE masklayer)
target_sources(mobileshellplugin PRIVATE ${mobileshellplugin_SRCS})

# Singleton declarations
set_source_files_properties(
    qml/components/AppLaunch.qml
    qml/components/Constants.qml
    qml/dataproviders/AudioInfo.qml
    qml/dataproviders/BatteryInfo.qml
    qml/dataproviders/BluetoothInfo.qml
    qml/dataproviders/NetworkInfo.qml
    qml/dataproviders/SignalStrengthInfo.qml
    qml/popups/PopupProviderLoader.qml
    PROPERTIES
    QT_QML_SINGLETON_TYPE TRUE
)

# QML files meant to be used publicly
# TODO: move files gradually out of main namespace into sub namespaces
ecm_target_qml_sources(mobileshellplugin SOURCES
    qml/actiondrawer/ActionDrawer.qml
    qml/actiondrawer/ActionDrawerOpenSurface.qml
    qml/actiondrawer/ActionDrawerWindow.qml

    qml/components/AppLaunch.qml
    qml/components/BaseItem.qml
    qml/components/Constants.qml
    qml/components/Flickable.qml
    qml/components/FlickableOpacityGradient.qml
    qml/components/GridView.qml
    qml/components/HapticsEffect.qml
    qml/components/ListView.qml
    qml/components/MarqueeLabel.qml
    qml/components/PanelBackground.qml
    qml/components/ScreenEdgeDragEffect.qml
    qml/components/StartupFeedbackPanelFill.qml
    qml/components/StartupFeedbackWindows.qml
    qml/components/TextDropShadow.qml
    qml/components/VelocityCalculator.qml

    qml/dataproviders/AudioInfo.qml
    qml/dataproviders/BatteryInfo.qml
    qml/dataproviders/BluetoothInfo.qml
    qml/dataproviders/NetworkInfo.qml
    qml/dataproviders/SignalStrengthInfo.qml

    qml/homescreen/BlurEffect.qml
    qml/homescreen/DeviceLock.qml
    qml/homescreen/HomeScreen.qml
    qml/homescreen/WallpaperSelector.qml

    qml/navigationpanel/GesturePanel.qml
    qml/navigationpanel/NavigationPanel.qml
    qml/navigationpanel/NavigationPanelAction.qml
    qml/navigationpanel/NavigationPanelButton.qml

    qml/popups/actionbuttons/ActionButton.qml
    qml/popups/actionbuttons/ActionButtonsProvider.qml
    qml/popups/actionbuttons/RotationButton.qml

    qml/popups/notifications/NotificationPopup.qml
    qml/popups/notifications/NotificationPopupManager.qml
    qml/popups/notifications/NotificationPopupProvider.qml
    qml/popups/notifications/PulseAudio.qml

    qml/popups/kscreenosd/KScreenOSDProvider.qml

    qml/popups/volumeosd/AudioApplet.qml
    qml/popups/volumeosd/DeviceListItem.qml
    qml/popups/volumeosd/icon.js
    qml/popups/volumeosd/ListItemBase.qml
    qml/popups/volumeosd/PopupCard.qml
    qml/popups/volumeosd/StreamListItem.qml
    qml/popups/volumeosd/VolumeChangedPopup.qml
    qml/popups/volumeosd/VolumeOSD.qml
    qml/popups/volumeosd/VolumeOSDProvider.qml
    qml/popups/volumeosd/VolumeSlider.qml
    qml/popups/PopupProviderLoader.qml

    qml/statusbar/indicators/BatteryIndicator.qml
    qml/statusbar/indicators/BluetoothIndicator.qml
    qml/statusbar/indicators/InternetIndicator.qml
    qml/statusbar/indicators/SignalStrengthIndicator.qml
    qml/statusbar/indicators/VolumeIndicator.qml
    qml/statusbar/ClockText.qml
    qml/statusbar/StatusBar.qml
    qml/statusbar/TaskWidget.qml

    qml/widgets/krunner/KRunnerScreen.qml
    qml/widgets/mediacontrols/BlurredBackground.qml
    qml/widgets/mediacontrols/MediaControlsSource.qml
    qml/widgets/mediacontrols/MediaControlsWidget.qml
    qml/widgets/notifications/BaseNotificationItem.qml
    qml/widgets/notifications/NotificationBodyLabel.qml
    qml/widgets/notifications/NotificationCard.qml
    qml/widgets/notifications/NotificationEditContextMenu.qml
    qml/widgets/notifications/NotificationFooterActions.qml
    qml/widgets/notifications/NotificationGroupHeader.qml
    qml/widgets/notifications/NotificationItem.qml
    qml/widgets/notifications/NotificationJobDetails.qml
    qml/widgets/notifications/NotificationJobItem.qml
    qml/widgets/notifications/NotificationPopupItem.qml
    qml/widgets/notifications/NotificationReplyField.qml
    qml/widgets/notifications/NotificationsModelType.qml
    qml/widgets/notifications/NotificationsUtils.js
    qml/widgets/notifications/NotificationsWidget.qml
    qml/widgets/notifications/NotificationTimeText.qml
    qml/widgets/notifications/ThumbnailStrip.qml
)

# Other supporting QML files
ecm_target_qml_sources(mobileshellplugin SOURCES
    qml/actiondrawer/private/BrightnessItem.qml
    qml/actiondrawer/private/Handle.qml
    qml/actiondrawer/private/QuickSettings.qml
    qml/actiondrawer/private/QuickSettingsDelegate.qml
    qml/actiondrawer/private/QuickSettingsDrawer.qml
    qml/actiondrawer/private/QuickSettingsFullDelegate.qml
    qml/actiondrawer/private/QuickSettingsMinimizedDelegate.qml
    qml/actiondrawer/private/QuickSettingsPanel.qml
    qml/actiondrawer/private/ContentContainer.qml
    qml/actiondrawer/private/LandscapeContentContainer.qml
    qml/actiondrawer/private/NotificationDrawer.qml
    qml/actiondrawer/private/PortraitContentContainer.qml
    PATH actiondrawer/private
)


target_link_libraries(mobileshellplugin
    PUBLIC
        Qt::Core
    PRIVATE
        Qt::DBus
        Qt::Qml
        Qt::Gui
        Qt::Quick
        Qt::WaylandClientPrivate
        KF6::KIOGui
        Plasma::Plasma
        KF6::I18n
        KF6::Notifications
        Plasma::PlasmaQuick
        KF6::KIOGui
        KF6::KIOWidgets # for PreviewJob
        KF6::Service
        KF6::Package
        KF6::ConfigGui
        LayerShellQt::Interface
)

ecm_finalize_qml_module(mobileshellplugin)
