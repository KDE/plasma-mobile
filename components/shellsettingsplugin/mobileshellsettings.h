/*
 *  SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

#pragma once

#include <KConfigGroup>
#include <KConfigWatcher>
#include <KSharedConfig>
#include <QDBusConnection>
#include <QObject>
#include <qqmlregistration.h>

/**
 * @short Wrapper class to access and control mobile shell specific settings.
 *
 * @author Devin Lin <devin@kde.org>
 */
class MobileShellSettings : public QObject
{
    Q_OBJECT
    QML_NAMED_ELEMENT(Settings)
    QML_SINGLETON

    // general
    Q_PROPERTY(bool vibrationsEnabled READ vibrationsEnabled WRITE setVibrationsEnabled NOTIFY vibrationsEnabledChanged)
    Q_PROPERTY(int vibrationDuration READ vibrationDuration WRITE setVibrationDuration NOTIFY vibrationDurationChanged)
    Q_PROPERTY(bool animationsEnabled READ animationsEnabled WRITE setAnimationsEnabled NOTIFY animationsEnabledChanged)

    // status bar
    Q_PROPERTY(bool dateInStatusBar READ dateInStatusBar WRITE setDateInStatusBar NOTIFY dateInStatusBarChanged)

    // navigation panel
    Q_PROPERTY(bool navigationPanelEnabled READ navigationPanelEnabled WRITE setNavigationPanelEnabled NOTIFY navigationPanelEnabledChanged)
    Q_PROPERTY(bool alwaysShowKeyboardToggleOnNavigationPanel READ alwaysShowKeyboardToggleOnNavigationPanel WRITE setAlwaysShowKeyboardToggleOnNavigationPanel
                   NOTIFY alwaysShowKeyboardToggleOnNavigationPanelChanged)

    // action drawer
    Q_PROPERTY(ActionDrawerMode actionDrawerTopLeftMode READ actionDrawerTopLeftMode WRITE setActionDrawerTopLeftMode NOTIFY actionDrawerTopLeftModeChanged)
    Q_PROPERTY(ActionDrawerMode actionDrawerTopRightMode READ actionDrawerTopRightMode WRITE setActionDrawerTopRightMode NOTIFY actionDrawerTopRightModeChanged)

    // convergence mode
    Q_PROPERTY(bool convergenceModeEnabled READ convergenceModeEnabled WRITE setConvergenceModeEnabled NOTIFY convergenceModeEnabledChanged)

public:
    MobileShellSettings(QObject *parent = nullptr);

    enum ActionDrawerMode {
        Pinned = 0, /** The drawer when pulled down is in its pinned mode. A second swipe fully expands it.*/
        Expanded /** The drawer is fully expanded when pulled down.*/
    };
    Q_ENUM(ActionDrawerMode)

    /**
     * Get whether shell vibrations are enabled.
     */
    bool vibrationsEnabled() const;

    /**
     * Set whether shell vibrations should be enabled.
     *
     * @param vibrationsEnabled Whether vibrations are enabled.
     */
    void setVibrationsEnabled(bool vibrationsEnabled);

    /**
     * Get the duration of a standard vibration event, in milliseconds.
     * Different types of vibration events may be calculated off of this.
     */
    int vibrationDuration() const;

    /**
     * Set the duration of a standard vibration event, in milliseconds.
     *
     * @param vibrationDuration The duration of a standard vibration event.
     */
    void setVibrationDuration(int vibrationDuration);

    /**
     * Whether animations are enabled in the shell.
     *
     * If false, vibrations will either be disabled or minimized as much as possible.
     * TODO: integrate with animation speed (in settings at "Workspace Behaviour->General Behaviour"),
     *       which affects applications as well.
     */
    bool animationsEnabled() const;

    /**
     * Set whether animations are enabled in the shell.
     *
     * @param animationsEnabled Whether animations should be enabled in the shell.
     */
    void setAnimationsEnabled(bool animationsEnabled);

    /**
     * Whether date is shown in the status bar.
     *
     * If true, date will be shown in the status bar next to the clock.
     */
    bool dateInStatusBar() const;

    /**
     * Set whether date is shown in the status bar.
     *
     * @param dateInStatusBar Whether date is shown in the status bar.
     */
    void setDateInStatusBar(bool dateInStatusBar);

    /**
     * Whether the navigation panel is enabled.
     *
     * If this is false, then gesture based navigation is used.
     */
    bool navigationPanelEnabled() const;

    /**
     * Set whether the navigation panel is enabled.
     *
     * @param navigationPanelEnabled Whether the navigation panel should be enabled.
     */
    void setNavigationPanelEnabled(bool navigationPanelEnabled);

    /**
     * Set whether the keyboard toggle button should always show on the navigation panel, regardless of
     * whether the app properly supports virtual keyboards.
     *
     * If this is false, then the keyboard toggle only shows on the navigation panel if the app doesn't
     * support virtual keyboards.
     */
    bool alwaysShowKeyboardToggleOnNavigationPanel() const;

    /**
     * Set whether the keyboard toggle button should always show on the navigation panel, regardless of
     * whether the app properly supports virtual keyboards.
     *
     * @param alwaysShowKeyboardToggleOnNavigationPanel
     */
    void setAlwaysShowKeyboardToggleOnNavigationPanel(bool alwaysShowKeyboardToggleOnNavigationPanel);

    /**
     * The mode of the action drawer when swiped down from the top left.
     */
    ActionDrawerMode actionDrawerTopLeftMode() const;

    /**
     * Set the mode of the action drawer when swiped down from the top left.
     *
     * @param actionDrawerMode The mode of the action drawer.
     */
    void setActionDrawerTopLeftMode(ActionDrawerMode actionDrawerMode);

    /**
     * The mode of the action drawer when swiped down from the top right.
     */
    ActionDrawerMode actionDrawerTopRightMode() const;

    /**
     * Set the mode of the action drawer when swiped down from the top right.
     *
     * @param actionDrawerMode The mode of the action drawer.
     */
    void setActionDrawerTopRightMode(ActionDrawerMode actionDrawerMode);

    /**
     * Whether convergence/docked mode is enabled.
     */
    bool convergenceModeEnabled() const;

    /**
     * Set whether convergence/docked mode is enabled.
     *
     * @param enabled
     */
    void setConvergenceModeEnabled(bool enabled);

Q_SIGNALS:
    void vibrationsEnabledChanged();
    void vibrationDurationChanged();
    void navigationPanelEnabledChanged();
    void alwaysShowKeyboardToggleOnNavigationPanelChanged();
    void keyboardButtonEnabledChanged();
    void animationsEnabledChanged();
    void dateInStatusBarChanged();
    void taskSwitcherPreviewsEnabledChanged();
    void actionDrawerTopLeftModeChanged();
    void actionDrawerTopRightModeChanged();
    void convergenceModeEnabledChanged();

private:
    void updateNavigationBarsInPlasma(bool navigationPanelEnabled);

    KConfigWatcher::Ptr m_configWatcher;
    KSharedConfig::Ptr m_config;
};
