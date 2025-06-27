// SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include <QObject>

#include <KConfigGroup>

class HalcyonSettings : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool showWallpaperBlur READ showWallpaperBlur WRITE setShowWallpaperBlur NOTIFY showWallpaperBlurChanged)
    Q_PROPERTY(bool doubleTapToLock READ doubleTapToLock WRITE setDoubleTapToLock NOTIFY doubleTapToLockChanged)

public:
    HalcyonSettings(QObject *parent = nullptr, KConfigGroup config = {});

    bool showWallpaperBlur() const;
    void setShowWallpaperBlur(bool blurWallpaper);

    bool doubleTapToLock() const;
    void setDoubleTapToLock(bool doubleTapToLock);

Q_SIGNALS:
    void showWallpaperBlurChanged();
    void doubleTapToLockChanged();

private:
    void save();
    void load();

    bool m_showWallpaperBlur{false};
    bool m_doubleTapToLock{true};

    KConfigGroup m_config;
};