/**
 * SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

#pragma once

#include <KConfigGroup>
#include <KQuickAddons/ManagedConfigModule>
#include <KSharedConfig>

class KCMMobileShell : public KQuickAddons::ManagedConfigModule
{
    Q_OBJECT
    Q_PROPERTY(bool navigationPanelEnabled READ navigationPanelEnabled WRITE setNavigationPanelEnabled NOTIFY navigationPanelEnabledChanged)

public:
    KCMMobileShell(QObject *parent, const KPluginMetaData &data, const QVariantList &args);
    virtual ~KCMMobileShell() override = default;

    bool navigationPanelEnabled() const;
    void setNavigationPanelEnabled(bool navigationPanelEnabled);

Q_SIGNALS:
    void navigationPanelEnabledChanged();

private:
    KSharedConfig::Ptr m_config;
};
