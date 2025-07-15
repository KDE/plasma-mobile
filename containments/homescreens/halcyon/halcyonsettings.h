// SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include <QObject>

#include <KConfigGroup>

#include <qqmlregistration.h>

class HalcyonSettings : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_UNCREATABLE("")
    Q_PROPERTY(HalcyonSettings::WallpaperBlurEffect wallpaperBlurEffect READ wallpaperBlurEffect WRITE setWallpaperBlurEffect NOTIFY wallpaperBlurEffectChanged)
    Q_PROPERTY(bool doubleTapToLock READ doubleTapToLock WRITE setDoubleTapToLock NOTIFY doubleTapToLockChanged)

public:
    HalcyonSettings(QObject *parent = nullptr, KConfigGroup config = {});

    enum WallpaperBlurEffect {
        None = 0,
        Simple = 1,
        Full = 2,
    };
    Q_ENUM(WallpaperBlurEffect)

    WallpaperBlurEffect wallpaperBlurEffect() const;
    void setWallpaperBlurEffect(WallpaperBlurEffect wallpaperBlurEffect);

    bool doubleTapToLock() const;
    void setDoubleTapToLock(bool doubleTapToLock);

Q_SIGNALS:
    void wallpaperBlurEffectChanged();
    void doubleTapToLockChanged();

private:
    void save();
    void load();

    WallpaperBlurEffect m_wallpaperBlurEffect{Full};
    bool m_doubleTapToLock{true};

    KConfigGroup m_config;
};
