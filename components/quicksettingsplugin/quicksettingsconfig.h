
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
class QuickSettingsConfig : public QObject
{
    Q_OBJECT

public:
    QuickSettingsConfig(QObject *parent = nullptr);

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
    void enabledQuickSettingsChanged();
    void disabledQuickSettingsChanged();

private:
    KConfigWatcher::Ptr m_configWatcher;
    KSharedConfig::Ptr m_config;
};
