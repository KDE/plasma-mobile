/*
 *  SPDX-FileCopyrightText: 2025 Florian RICHER <florian.richer@protonmail.com>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

#pragma once

#include <KConfigGroup>
#include <KConfigWatcher>
#include <KSharedConfig>
#include <qobject.h>
#include <qqmlintegration.h>

class KWinSettings : public QObject
{
    Q_OBJECT
    QML_NAMED_ELEMENT(KWinSettings)
    QML_SINGLETON

    Q_PROPERTY(bool doubleTapWakeup READ doubleTapWakeup WRITE setDoubleTapWakeup NOTIFY doubleTapWakeupChanged)
    Q_PROPERTY(bool overlayVirtualKeyboardOnWindows READ overlayVirtualKeyboardOnWindows WRITE setOverlayVirtualKeyboardOnWindows NOTIFY
                   overlayVirtualKeyboardOnWindowsChanged)
    Q_PROPERTY(int screenEdgeTouchTarget READ screenEdgeTouchTarget WRITE setScreenEdgeTouchTarget NOTIFY screenEdgeTouchTargetChanged)

public:
    KWinSettings(QObject *parent = nullptr);

    /**
     * Whether Double Tap to Wakeup is enabled.
     */
    bool doubleTapWakeup() const;

    /**
     * Set whether Double Tap to Wakeup is enabled.
     *
     * @param enabled
     */
    void setDoubleTapWakeup(bool enabled);

    /**
     * Whether the virtual keyboard overlays application windows instead of resizing them.
     */
    bool overlayVirtualKeyboardOnWindows() const;

    /**
     * Set whether the virtual keyboard overlays application windows.
     *
     * @param enabled
     */
    void setOverlayVirtualKeyboardOnWindows(bool enabled);

    /**
     * Get the screen edge touch target value.
     */
    int screenEdgeTouchTarget() const;

    /**
     * Set the screen edge touch target value.
     *
     * @param target
     */
    void setScreenEdgeTouchTarget(int target);

Q_SIGNALS:
    void doubleTapWakeupChanged();
    void overlayVirtualKeyboardOnWindowsChanged();
    void screenEdgeTouchTargetChanged();

private:
    KConfigWatcher::Ptr m_configWatcher;
    KSharedConfig::Ptr m_config;
    KSharedConfig::Ptr m_overlayConfig;
};
