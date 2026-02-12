// SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include <QObject>

#include <KConfigGroup>

#include <Plasma/Applet>

#include <qqmlregistration.h>

class HalcyonSettings : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_UNCREATABLE("")
    Q_PROPERTY(HalcyonSettings::WallpaperBlurEffect wallpaperBlurEffect READ wallpaperBlurEffect WRITE setWallpaperBlurEffect NOTIFY wallpaperBlurEffectChanged)
    Q_PROPERTY(bool doubleTapToLock READ doubleTapToLock WRITE setDoubleTapToLock NOTIFY doubleTapToLockChanged)

public:
    HalcyonSettings(Plasma::Applet *applet = nullptr, QObject *parent = nullptr);

    enum WallpaperBlurEffect {
        None = 0,
        Simple = 1,
        Full = 2,
    };
    Q_ENUM(WallpaperBlurEffect)

    QString pinned() const;
    void setPinned(const QString &pinnedJson);

    WallpaperBlurEffect wallpaperBlurEffect() const;
    void setWallpaperBlurEffect(WallpaperBlurEffect wallpaperBlurEffect);

    bool doubleTapToLock() const;
    void setDoubleTapToLock(bool doubleTapToLock);

    Q_INVOKABLE void load();

Q_SIGNALS:
    void wallpaperBlurEffectChanged();
    void doubleTapToLockChanged();

private:
    void save();
    KConfigGroup configGroup() const;

    void migrateConfigFromPlasma6_4();

    WallpaperBlurEffect m_wallpaperBlurEffect{Full};
    bool m_doubleTapToLock{true};

    Plasma::Applet *m_applet;
};
