# SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
# SPDX-License-Identifier: GPL-2.0-or-later

qt_add_dbus_interfaces(DBUS_SRCS dbus/org.kde.KWin.ScreenShot2.xml
                                 dbus/org.kde.KScreen.xml)

set(mobileshellplugin_SRCS
    mobileshellplugin.cpp
    shellutil.cpp
    quicksettingsmodel.cpp
    notifications/notificationthumbnailer.cpp
    notifications/notificationfilemenu.cpp
    ${DBUS_SRCS}
)

add_library(mobileshellplugin ${mobileshellplugin_SRCS})

target_link_libraries(mobileshellplugin
        PUBLIC
            Qt::Core
        PRIVATE
            Qt::DBus
            Qt::Qml
            Qt::Gui
            Qt::Quick
            KF5::ConfigWidgets # for KStandardAction
            KF5::KIOGui
            KF5::Plasma
            KF5::I18n
            KF5::Notifications
            KF5::PlasmaQuick
            KF5::KIOGui
            KF5::KIOWidgets # for PreviewJob
            KF5::WaylandClient
            KF5::Service
    )

install(TARGETS mobileshellplugin DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/plasma/private/mobileshell)

install(DIRECTORY qml/ DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/plasma/private/mobileshell)
