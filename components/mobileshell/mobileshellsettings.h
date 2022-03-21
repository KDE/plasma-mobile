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

class MobileShellSettings : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool navigationPanelEnabled READ navigationPanelEnabled WRITE setNavigationPanelEnabled NOTIFY navigationPanelEnabledChanged)

public:
    static MobileShellSettings *self();

    MobileShellSettings(QObject *parent = nullptr);

    bool navigationPanelEnabled() const;
    void setNavigationPanelEnabled(bool navigationPanelEnabled);

    QList<QString> enabledQuickSettings() const;
    void setEnabledQuickSettings(QList<QString> &list);

    QList<QString> disabledQuickSettings() const;
    void setDisabledQuickSettings(QList<QString> &list);

Q_SIGNALS:
    void navigationPanelEnabledChanged();
    void enabledQuickSettingsChanged();
    void disabledQuickSettingsChanged();

private:
    KConfigWatcher::Ptr m_configWatcher;
    KSharedConfig::Ptr m_config;
};
