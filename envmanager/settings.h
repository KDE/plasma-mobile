// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-FileCopyrightText: 2024 Luis Büchi <luis.buechi@kdemail.net>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include <QObject>

#include <KConfigGroup>
#include <KConfigWatcher>
#include <KSharedConfig>

class Settings : public QObject
{
    Q_OBJECT

public:
    Settings(QObject *parent = nullptr);
    static Settings &self();

    // apply the configuration
    void applyConfiguration();

private:
    // loads the saved configuration, so it can be restored on desktop
    void loadSavedConfiguration();

    // applies our mobile configuration
    void applyMobileConfiguration();

    void writeKeys(const QString &fileName, KSharedConfig::Ptr &config, const QMap<QString, QMap<QString, QVariant>> &settings);

    void loadKeys(const QString &fileName, KSharedConfig::Ptr &config, const QMap<QString, QMap<QString, QVariant>> &settings);
    void saveConfigSetting(const QString &fileName, const QString &group, const QString &key, const QVariant value);
    const QString loadSavedConfigSetting(KSharedConfig::Ptr &config, const QString &fileName, const QString &group, const QString &key, bool write = true);

    KSharedConfig::Ptr kwinrcConfig() const;
    void reloadKWinConfig();

    // whether this is Plasma Mobile
    bool m_isMobilePlatform;

    KSharedConfig::Ptr m_mobileConfig;

    // For legacy upgrade purposes
    KSharedConfig::Ptr m_originalKdeglobalsConfig; // (~/.config/kdeglobals)
};
