// SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

#include "savedquicksettings.h"

#include <QFileInfo>

SavedQuickSettings::SavedQuickSettings(QObject *parent)
    : QObject{parent}
    , m_settings{new QuickSettingsConfig{this}}
    , m_enabledQSModel{new SavedQuickSettingsModel{this}}
    , m_disabledQSModel{new SavedQuickSettingsModel{this}}
    , m_updateTimer{new QTimer{this}}
    , m_saveTimer{new QTimer{this}}
{
    // throttle model updates from config, to avoid performance issues with fast reloading
    m_updateTimer->setInterval(2000);
    m_updateTimer->setSingleShot(true);
    connect(m_updateTimer, &QTimer::timeout, this, [this]() {
        refreshModel();
    });

    // throttle saving so that we don't have conflicts while writing and then getting notified about updates
    m_saveTimer->setInterval(1000);
    m_saveTimer->setSingleShot(true);
    connect(m_saveTimer, &QTimer::timeout, this, [this]() {
        saveModel();
    });

    // load quicksettings packages
    auto packages = KPluginMetaData::findPlugins("plasma/mobile/quicksettings");
    for (auto &metaData : packages) {
        if (!metaData.isValid()) {
            qWarning() << "Quick setting metadata invalid:" << metaData.fileName();
            continue;
        }
        m_validPackages.push_back(metaData);
    }

    // subscribe to config changes
    connect(m_settings, &QuickSettingsConfig::enabledQuickSettingsChanged, this, [this]() {
        m_updateTimer->start();
    });
    connect(m_settings, &QuickSettingsConfig::disabledQuickSettingsChanged, this, [this]() {
        m_updateTimer->start();
    });

    // subscribe to model changes
    connect(m_enabledQSModel, &SavedQuickSettingsModel::dataUpdated, this, [this](QList<KPluginMetaData> data) -> void {
        m_enabledPackages.clear();
        for (auto metaData : data) {
            m_enabledPackages.push_back(metaData);
        }

        m_saveTimer->start();
        if (m_updateTimer->isActive()) {
            m_updateTimer->start(); // reset update timer if it's running
        }
    });
    connect(m_disabledQSModel, &SavedQuickSettingsModel::dataUpdated, this, [this](QList<KPluginMetaData> data) -> void {
        m_disabledPackages.clear();
        for (auto metaData : data) {
            m_disabledPackages.push_back(metaData);
        }

        m_saveTimer->start();
        if (m_updateTimer->isActive()) {
            m_updateTimer->start(); // reset update timer if it's running
        }
    });

    // load
    refreshModel();
}

SavedQuickSettings::~SavedQuickSettings()
{
    // save immediately if was requested
    if (m_saveTimer->isActive()) {
        saveModel();
    }
}

SavedQuickSettingsModel *SavedQuickSettings::enabledQuickSettingsModel() const
{
    return m_enabledQSModel;
}

SavedQuickSettingsModel *SavedQuickSettings::disabledQuickSettingsModel() const
{
    return m_disabledQSModel;
}

void SavedQuickSettings::enableQS(int index)
{
    KPluginMetaData tmp = m_disabledQSModel->takeRow(index);

    if (!tmp.isValid()) {
        return;
    }

    m_enabledQSModel->insertRow(tmp, m_enabledQSModel->rowCount({}));
}

void SavedQuickSettings::disableQS(int index)
{
    KPluginMetaData tmp = m_enabledQSModel->takeRow(index);

    if (!tmp.isValid()) {
        return;
    }

    m_disabledQSModel->insertRow(tmp, m_disabledQSModel->rowCount({}));
}

void SavedQuickSettings::refreshModel()
{
    QList<QString> enabledQS = m_settings->enabledQuickSettings();
    QList<QString> disabledQS = m_settings->disabledQuickSettings();

    m_enabledPackages.clear();
    m_disabledPackages.clear();

    // add enabled quick settings in order
    for (const QString &pluginId : enabledQS) {
        for (auto &metaData : m_validPackages) {
            if (pluginId == metaData.pluginId()) {
                m_enabledPackages.push_back(metaData);
                break;
            }
        }
    }

    // add disabled quick settings in order
    for (const QString &pluginId : disabledQS) {
        for (auto &metaData : m_validPackages) {
            if (pluginId == metaData.pluginId()) {
                m_disabledPackages.push_back(metaData);
                break;
            }
        }
    }

    // add undefined quick settings to the back of enabled quick settings
    for (auto &metaData : m_validPackages) {
        if (!enabledQS.contains(metaData.pluginId()) && !disabledQS.contains(metaData.pluginId())) {
            m_enabledPackages.push_back(metaData);
        }
    }

    m_enabledQSModel->updateData(m_enabledPackages);
    m_disabledQSModel->updateData(m_disabledPackages);
}

void SavedQuickSettings::saveModel()
{
    QList<QString> enabledQS;
    QList<QString> disabledQS;

    for (auto &metaData : m_enabledPackages) {
        enabledQS.push_back(metaData.pluginId());
    }
    for (auto &metaData : m_disabledPackages) {
        disabledQS.push_back(metaData.pluginId());
    }

    m_settings->setEnabledQuickSettings(enabledQS);
    m_settings->setDisabledQuickSettings(disabledQS);
}
