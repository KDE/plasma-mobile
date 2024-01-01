// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include <QObject>
#include <QQmlPropertyMap>
#include <QQuickItem>
#include <qqmlregistration.h>

#include <KConfig>
#include <KConfigGroup>
#include <KConfigLoader>
#include <KConfigPropertyMap>
#include <KConfigWatcher>

#include <PlasmaQuick/ConfigModel>

#include <QCoroDBusPendingReply>

class WallpaperConfigModel;
class WallpaperPlugin : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON
    Q_PROPERTY(bool usingDarkTheme READ usingDarkTheme WRITE setUsingDarkTheme NOTIFY usingDarkThemeChanged)
    Q_PROPERTY(QString themeName READ themeName WRITE setThemeName NOTIFY themeNameChanged)

public:
    bool usingDarkTheme() const;
    void setUsingDarkTheme(bool usingDarkTheme);
}