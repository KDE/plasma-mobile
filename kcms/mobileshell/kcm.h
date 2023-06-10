/**
 * SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

#pragma once

#include <KConfigGroup>
#include <KQuickManagedConfigModule>
#include <KSharedConfig>

class KCMMobileShell : public KQuickManagedConfigModule
{
    Q_OBJECT

public:
    KCMMobileShell(QObject *parent, const KPluginMetaData &data);

Q_SIGNALS:
    void navigationPanelEnabledChanged();

private:
    KSharedConfig::Ptr m_config;
};
