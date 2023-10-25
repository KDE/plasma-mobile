# SPDX-FileCopyrightText: Alexey Andreyev <aa13q@ya.ru>
# SPDX-License-Identifier: CC0-1.0

cmake_minimum_required(VERSION 3.16)
project(mobile-task-switcher)

find_package(ECM 5.240 REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH})

find_package(KF6 5.240 REQUIRED COMPONENTS
    Package
)

kpackage_install_package(package mobile-task-switcher effects kwin)
