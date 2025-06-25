// SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "halcyonsettings.h"

const QString CFG_KEY_SHOW_WALLPAPER_BLUR = QStringLiteral("showWallpaperBlur");
const QString CFG_KEY_DOUBLE_TAP_TO_SLEEP = QStringLiteral("doubleTapToSleep");

HalcyonSettings::HalcyonSettings(QObject *parent, KConfigGroup config)
    : QObject{parent}
    , m_config{config}
{
    load();
}

bool HalcyonSettings::showWallpaperBlur() const
{
    return m_showWallpaperBlur;
}

void HalcyonSettings::setShowWallpaperBlur(bool showWallpaperBlur)
{
    if (m_showWallpaperBlur != showWallpaperBlur) {
        m_showWallpaperBlur = showWallpaperBlur;
        Q_EMIT showWallpaperBlurChanged();
        save();
    }
}

bool HalcyonSettings::doubleTapToSleep() const
{
    return m_doubleTapToSleep;
}

void HalcyonSettings::setDoubleTapToSleep(bool doubleTapToSleep)
{
    if (m_doubleTapToSleep != doubleTapToSleep) {
        m_doubleTapToSleep = doubleTapToSleep;
        Q_EMIT doubleTapToSleepChanged();
        save();
    }
}

void HalcyonSettings::save()
{
    m_config.writeEntry(CFG_KEY_SHOW_WALLPAPER_BLUR, m_showWallpaperBlur);
    m_config.writeEntry(CFG_KEY_DOUBLE_TAP_TO_SLEEP, m_doubleTapToSleep);

    m_config.sync();
}

void HalcyonSettings::load()
{
    m_showWallpaperBlur = m_config.readEntry(CFG_KEY_SHOW_WALLPAPER_BLUR, false);
    m_doubleTapToSleep = m_config.readEntry(CFG_KEY_DOUBLE_TAP_TO_SLEEP, true);
}