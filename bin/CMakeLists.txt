# SPDX-FileCopyrightText: 2019 Aleix Pol <apol@kde.org>
# SPDX-FileCopyrightText: 2020 Jonah Brüchert <jbb@kaidan.im>
# SPDX-License-Identifier: GPL-2.0-or-later

configure_file(kwinwrapper.in ${CMAKE_CURRENT_BINARY_DIR}/kwinwrapper)
install(PROGRAMS ${CMAKE_CURRENT_BINARY_DIR}/kwinwrapper DESTINATION ${KDE_INSTALL_BINDIR})

configure_file(plasma-mobile.desktop.cmake ${CMAKE_CURRENT_BINARY_DIR}/plasma-mobile.desktop)
install(FILES
        ${CMAKE_CURRENT_BINARY_DIR}/plasma-mobile.desktop
        DESTINATION ${KDE_INSTALL_DATADIR}/wayland-sessions
)
