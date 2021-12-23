# SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
# SPDX-FileCopyrightText: 2021 Marco Martin <mart@kde.org>
# SPDX-FileCopyrightText: 2021 Aleix Pol <apol@kde.org>
# SPDX-License-Identifier: GPL-2.0-or-later

set(mobilehomescreencomponentsplugin_SRCS
    mobilehomescreencomponentsplugin.cpp
    applicationlistmodel.cpp
    favoritesmodel.cpp
    homescreenutils.cpp
)

add_library(mobilehomescreencomponentsplugin ${mobilehomescreencomponentsplugin_SRCS})

target_link_libraries(mobilehomescreencomponentsplugin
        PUBLIC
            Qt::Core
        PRIVATE
            Qt::Qml
            Qt::Quick
            KF5::KIOGui
            KF5::Plasma
            KF5::Notifications
            KF5::PlasmaQuick
            KF5::WaylandClient
    )

install(TARGETS mobilehomescreencomponentsplugin DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/plasma/private/mobilehomescreencomponents)

install(DIRECTORY qml/ DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/plasma/private/mobilehomescreencomponents)
