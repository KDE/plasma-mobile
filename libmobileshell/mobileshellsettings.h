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

#include "mobileshell_export.h"

namespace MobileShell
{

class MOBILESHELL_EXPORT MobileShellSettings : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool navigationPanelEnabled READ navigationPanelEnabled WRITE setNavigationPanelEnabled NOTIFY navigationPanelEnabledChanged)

public:
    static MobileShellSettings *self();

    MobileShellSettings(QObject *parent = nullptr);

    QString homeScreenType() const;
    void setHomeScreenType(QString homeScreenType);

    bool navigationPanelEnabled() const;
    void setNavigationPanelEnabled(bool navigationPanelEnabled);

    QList<QString> enabledQuickSettings() const;
    void setEnabledQuickSettings(QList<QString> &list);

    QList<QString> disabledQuickSettings() const;
    void setDisabledQuickSettings(QList<QString> &list);

Q_SIGNALS:
    void homeScreenTypeChanged();
    void navigationPanelEnabledChanged();
    void enabledQuickSettingsChanged();
    void disabledQuickSettingsChanged();

private:
    KConfigWatcher::Ptr m_configWatcher;
    KSharedConfig::Ptr m_config;
};

} // namespace MobileShell
