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
    Q_PROPERTY(bool navigationPanelEnabled READ navigationPanelEnabled NOTIFY navigationPanelEnabledChanged)

public:
    static MobileShellSettings *self();

    MobileShellSettings(QObject *parent = nullptr);

    bool navigationPanelEnabled() const;

Q_SIGNALS:
    void navigationPanelEnabledChanged();

private:
    KConfigWatcher::Ptr m_configWatcher;
    KSharedConfig::Ptr m_config;
};
