/*
 *  SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

#pragma once

#include <KConfigGroup>
#include <KConfigWatcher>
#include <KSharedConfig>
#include <QObject>

/**
 * @short Wrapper class to access and control mobile shell specific settings.
 *
 * @author Devin Lin <devin@kde.org>
 */
class MobileShellSettings : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool vibrationsEnabled READ vibrationsEnabled WRITE setVibrationsEnabled NOTIFY vibrationsEnabledChanged)
    Q_PROPERTY(int vibrationDuration READ vibrationDuration WRITE setVibrationDuration NOTIFY vibrationDurationChanged)
    Q_PROPERTY(qreal vibrationIntensity READ vibrationIntensity WRITE setVibrationIntensity NOTIFY vibrationIntensityChanged)
    Q_PROPERTY(bool animationsEnabled READ animationsEnabled WRITE setAnimationsEnabled NOTIFY animationsEnabledChanged)
    Q_PROPERTY(bool navigationPanelEnabled READ navigationPanelEnabled WRITE setNavigationPanelEnabled NOTIFY navigationPanelEnabledChanged)

public:
    static MobileShellSettings *self();

    MobileShellSettings(QObject *parent = nullptr);

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
     * Get the intensity of a standard vibration event, which is a value between
     * zero and one.
     */
    qreal vibrationIntensity() const;

    /**
     * Set the intensity of a standard vibration event.
     *
     * @param vibrationIntensity The intensity of a standard vibration event, between zero and one.
     */
    void setVibrationIntensity(qreal vibrationIntensity);

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
     * Get the list of IDs of quick settings that are enabled.
     */
    QList<QString> enabledQuickSettings() const;

    /**
     * Set the list of quick settings that are enabled.
     *
     * @param list A list of quick setting IDs.
     */
    void setEnabledQuickSettings(QList<QString> &list);

    /**
     * Get the list of IDs of quick settings that are disabled.
     */
    QList<QString> disabledQuickSettings() const;

    /**
     * Set the list of quick settings that are disabled.
     *
     * @param list A list of quick setting IDs.
     */
    void setDisabledQuickSettings(QList<QString> &list);

Q_SIGNALS:
    void vibrationsEnabledChanged();
    void vibrationIntensityChanged();
    void vibrationDurationChanged();
    void navigationPanelEnabledChanged();
    void animationsEnabledChanged();
    void enabledQuickSettingsChanged();
    void disabledQuickSettingsChanged();

private:
    KConfigWatcher::Ptr m_configWatcher;
    KSharedConfig::Ptr m_config;
};
