// SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "halcyonsettings.h"

const QString CFG_KEY_SHOW_WALLPAPER_BLUR = QStringLiteral("wallpaperBlurEffect");
const QString CFG_KEY_DOUBLE_TAP_TO_LOCK = QStringLiteral("doubleTapToLock");

HalcyonSettings::HalcyonSettings(QObject *parent, KConfigGroup config)
: QObject{parent}
, m_config{config}
{
    load();
}

HalcyonSettings::WallpaperBlurEffect HalcyonSettings::wallpaperBlurEffect() const
{
    return m_wallpaperBlurEffect;
}

void HalcyonSettings::setWallpaperBlurEffect(WallpaperBlurEffect wallpaperBlurEffect)
{
    if (m_wallpaperBlurEffect != wallpaperBlurEffect) {
        m_wallpaperBlurEffect = wallpaperBlurEffect;
        Q_EMIT wallpaperBlurEffectChanged();
        save();
    }
}

bool HalcyonSettings::doubleTapToLock() const
{
    return m_doubleTapToLock;
}

void HalcyonSettings::setDoubleTapToLock(bool doubleTapToLock)
{
    if (m_doubleTapToLock != doubleTapToLock) {
        m_doubleTapToLock = doubleTapToLock;
        Q_EMIT doubleTapToLockChanged();
        save();
    }
}

void HalcyonSettings::save()
{
    m_config.writeEntry(CFG_KEY_SHOW_WALLPAPER_BLUR, (int)m_wallpaperBlurEffect);
    m_config.writeEntry(CFG_KEY_DOUBLE_TAP_TO_LOCK, m_doubleTapToLock);

    m_config.sync();
}

void HalcyonSettings::load()
{
    m_wallpaperBlurEffect = static_cast<WallpaperBlurEffect>(m_config.readEntry(CFG_KEY_SHOW_WALLPAPER_BLUR, (int)Full));
    m_doubleTapToLock = m_config.readEntry(CFG_KEY_DOUBLE_TAP_TO_LOCK, true);

    Q_EMIT doubleTapToLockChanged();
    Q_EMIT wallpaperBlurEffectChanged();
}
