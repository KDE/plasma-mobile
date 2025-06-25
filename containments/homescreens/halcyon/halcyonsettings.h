// SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include <QObject>

#include <KConfigGroup>

class HalcyonSettings : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool showWallpaperBlur READ showWallpaperBlur WRITE setShowWallpaperBlur NOTIFY showWallpaperBlurChanged)
    Q_PROPERTY(bool doubleTapToSleep READ doubleTapToSleep WRITE setDoubleTapToSleep NOTIFY doubleTapToSleepChanged)

public:
    HalcyonSettings(QObject *parent = nullptr, KConfigGroup config = {});

    bool showWallpaperBlur() const;
    void setShowWallpaperBlur(bool blurWallpaper);

    bool doubleTapToSleep() const;
    void setDoubleTapToSleep(bool doubleTapToSleep);

Q_SIGNALS:
    void showWallpaperBlurChanged();
    void doubleTapToSleepChanged();

private:
    void save();
    void load();

    bool m_showWallpaperBlur{false};
    bool m_doubleTapToSleep{true};

    KConfigGroup m_config;
};