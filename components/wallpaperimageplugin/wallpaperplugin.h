// SPDX-FileCopyrightText: 2023 Méven Car <meven@kde.org>
// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include <QObject>
#include <QQmlPropertyMap>
#include <QQuickItem>
#include <qqmlregistration.h>

#include <KConfig>
#include <KConfigGroup>
#include <KConfigLoader>
#include <KConfigPropertyMap>
#include <KConfigWatcher>

#include <PlasmaQuick/ConfigModel>

#include <QCoroDBusPendingReply>

class WallpaperConfigModel;
class WallpaperPlugin : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    Q_PROPERTY(QString homescreenWallpaperPath READ homescreenWallpaperPath NOTIFY homescreenWallpaperPathChanged)
    Q_PROPERTY(QString lockscreenWallpaperPath READ lockscreenWallpaperPath NOTIFY lockscreenWallpaperPathChanged)

    Q_PROPERTY(QQmlPropertyMap *homescreenConfiguration READ homescreenConfiguration NOTIFY homescreenConfigurationChanged)
    Q_PROPERTY(QQmlPropertyMap *lockscreenConfiguration READ lockscreenConfiguration NOTIFY lockscreenConfigurationChanged)
    Q_PROPERTY(PlasmaQuick::ConfigModel *wallpaperPluginModel READ wallpaperPluginModel CONSTANT)

    Q_PROPERTY(QString homescreenWallpaperPlugin READ homescreenWallpaperPlugin WRITE setHomescreenWallpaperPlugin NOTIFY homescreenWallpaperPluginChanged)
    Q_PROPERTY(QString homescreenWallpaperPluginSource READ homescreenWallpaperPluginSource NOTIFY homescreenWallpaperPluginChanged)
    Q_PROPERTY(QString lockscreenWallpaperPlugin READ lockscreenWallpaperPlugin WRITE setLockscreenWallpaperPlugin NOTIFY lockscreenWallpaperPluginChanged)
    Q_PROPERTY(QString lockscreenWallpaperPluginSource READ lockscreenWallpaperPluginSource NOTIFY lockscreenWallpaperPluginChanged)

public:
    WallpaperPlugin(QObject *parent = nullptr);

    PlasmaQuick::ConfigModel *wallpaperPluginModel();
    QQmlPropertyMap *homescreenConfiguration() const;
    QQmlPropertyMap *lockscreenConfiguration() const;

    QString homescreenWallpaperPlugin() const;
    QString homescreenWallpaperPluginSource();
    Q_INVOKABLE void setHomescreenWallpaperPlugin(const QString &wallpaperPlugin);
    QString lockscreenWallpaperPlugin() const;
    QString lockscreenWallpaperPluginSource();
    Q_INVOKABLE void setLockscreenWallpaperPlugin(const QString &wallpaperPlugin);

    // changes the plugin to org.kde.image and sets an image
    Q_INVOKABLE QCoro::Task<void> setHomescreenWallpaper(const QString &path);
    Q_INVOKABLE void setLockscreenWallpaper(const QString &path);

    QString homescreenWallpaperPath();
    QString lockscreenWallpaperPath();

    Q_INVOKABLE QCoro::Task<void> saveHomescreenSettings();
    Q_INVOKABLE void saveLockscreenSettings();

public Q_SLOTS:
    QCoro::Task<void> loadHomescreenSettings();
    void loadLockscreenSettings();

Q_SIGNALS:
    void homescreenWallpaperPathChanged();
    void lockscreenWallpaperPathChanged();
    void homescreenConfigurationChanged();
    void lockscreenConfigurationChanged();
    void currentWallpaperPluginChanged();
    void homescreenWallpaperPluginChanged();
    void lockscreenWallpaperPluginChanged();

private:
    QQmlPropertyMap *loadConfiguration(KConfigGroup group, QString wallpaperPlugin, bool loadDefaults);

    QString m_homescreenWallpaperPlugin;
    QString m_lockscreenWallpaperPlugin;

    QString m_homescreenWallpaperPath;
    QString m_lockscreenWallpaperPath;

    QQmlPropertyMap *m_homescreenConfig{nullptr};
    QQmlPropertyMap *m_lockscreenConfig{nullptr};

    KSharedConfig::Ptr m_homescreenConfigFile{nullptr};
    KSharedConfig::Ptr m_lockscreenConfigFile{nullptr};
    KConfigWatcher::Ptr m_lockscreenConfigWatcher{nullptr};

    WallpaperConfigModel *m_wallpaperPluginModel = nullptr;
};

class WallpaperConfigModel : public PlasmaQuick::ConfigModel
{
    Q_OBJECT

public:
    WallpaperConfigModel(QObject *parent);
public Q_SLOTS:
    void repopulate();
};
