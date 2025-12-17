# SPDX-FileCopyrightText: 2015-2016 Marco Martin <mart@kde.org>
# SPDX-FileCopyrightText: 2021 Aleix Pol <apol@kde.org>
# SPDX-FileCopyrightText: 2021 Nicolas Fella <nicolas.fella@kde.org>
# SPDX-License-Identifier: GPL-2.0-or-later

plasma_add_applet(org.kde.plasma.mobile.taskpanel
    QML_SOURCES
        qml/main.qml
        qml/NavigationPanelComponent.qml
        qml/GesturePanelComponent.qml
    CPP_SOURCES
        taskpanel.cpp
)

target_link_libraries(org.kde.plasma.mobile.taskpanel PRIVATE
                      Qt::Gui
                      Qt::DBus
                      Qt::Qml
                      Qt::Quick
                      Qt::Sensors
                      Plasma::Plasma
                      KF6::Screen
                    )
