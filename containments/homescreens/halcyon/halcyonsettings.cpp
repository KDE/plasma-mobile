// SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "halcyonsettings.h"

using namespace Qt::Literals::StringLiterals;

// The config group all of the settings are under
static constexpr auto CFG_GROUP_HALCYON = "Halcyon"_L1;

static constexpr auto CFG_KEY_PINNED = "pinned"_L1;
static constexpr auto CFG_KEY_SHOW_WALLPAPER_BLUR = "wallpaperBlurEffect"_L1;
static constexpr auto CFG_KEY_DOUBLE_TAP_TO_LOCK = "doubleTapToLock"_L1;

HalcyonSettings::HalcyonSettings(Plasma::Applet *applet, QObject *parent)
    : QObject{parent}
    , m_applet{applet}
{
}

QString HalcyonSettings::pinned() const
{
    return configGroup().readEntry(CFG_KEY_PINNED, u"{}"_s);
}

void HalcyonSettings::setPinned(const QString &pinnedJson)
{
    // Saved separately from other options, since it's changed from the homescreen (not settings window)
    configGroup().writeEntry(CFG_KEY_PINNED, pinnedJson);
    m_applet->config().sync();
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
    auto group = configGroup();
    group.writeEntry(CFG_KEY_SHOW_WALLPAPER_BLUR, (int)m_wallpaperBlurEffect);
    group.writeEntry(CFG_KEY_DOUBLE_TAP_TO_LOCK, m_doubleTapToLock);

    m_applet->config().sync();
}

void HalcyonSettings::load()
{
    migrateConfigFromPlasma6_4();

    auto group = configGroup();
    m_wallpaperBlurEffect = static_cast<WallpaperBlurEffect>(group.readEntry(CFG_KEY_SHOW_WALLPAPER_BLUR, (int)Full));
    m_doubleTapToLock = group.readEntry(CFG_KEY_DOUBLE_TAP_TO_LOCK, true);

    Q_EMIT doubleTapToLockChanged();
    Q_EMIT wallpaperBlurEffectChanged();
}

KConfigGroup HalcyonSettings::configGroup() const
{
    if (!m_applet) {
        return KConfigGroup{};
    }

    return m_applet->config().group(CFG_GROUP_HALCYON);
}

void HalcyonSettings::migrateConfigFromPlasma6_4()
{
    // Migrate config options (from before Plasma 6.5) from the root config group to [General]
    // When adding new config options, do not update this function!

    auto oldConfigGroup = m_applet->config();
    auto newConfigGroup = configGroup();

    const QString oldKey = u"Pinned"_s;
    if (!oldConfigGroup.hasKey(oldKey) || newConfigGroup.hasKey(CFG_KEY_PINNED)) {
        return;
    }

    newConfigGroup.writeEntry(CFG_KEY_PINNED, oldConfigGroup.readEntry(oldKey, u"{}"_s));
    oldConfigGroup.deleteEntry(oldKey);

    m_applet->config().sync();
}
