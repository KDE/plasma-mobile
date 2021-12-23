/*
 * SPDX-FileCopyrightText: 2019 by Marco Martin <mart@kde.org>
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

#pragma once

#include <QUrl>

#include <QQmlEngine>
#include <QQmlExtensionPlugin>

class MobileHomeScreenComponentsPlugin : public QQmlExtensionPlugin
{
    Q_OBJECT
    Q_PLUGIN_METADATA(IID "org.qt-project.Qt.QQmlExtensionInterface")

public:
    void registerTypes(const char *uri) override;
};
