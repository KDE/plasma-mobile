// SPDX-FileCopyrightText: 2025 Sebastian Kügler <sebas@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include <QUrl>

#include <QQmlEngine>
#include <QQmlExtensionPlugin>

class KScreenOSDPlugin : public QQmlExtensionPlugin
{
    Q_OBJECT
    Q_PLUGIN_METADATA(IID "org.qt-project.Qt.QQmlExtensionInterface")

public:
    void registerTypes(const char *uri) override;
};
