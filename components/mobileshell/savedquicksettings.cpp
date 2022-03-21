// SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

#include "savedquicksettings.h"

#include <KPackage/PackageLoader>

#include <QFileInfo>

SavedQuickSettings::SavedQuickSettings(QObject *parent)
    : QObject{parent}
    , m_settings{new MobileShellSettings{this}}
    , m_validPackages{}
    , m_enabledPackages{}
    , m_disabledPackages{}
    , m_enabledQSModel{new SavedQuickSettingsModel{this}}
    , m_disabledQSModel{new SavedQuickSettingsModel{this}}
    , m_updateTimer{new QTimer{this}}
{
    // throttle model updates from config, to avoid performance issues with fast reloading
    m_updateTimer->setInterval(2000);
    m_updateTimer->setSingleShot(true);
    connect(m_updateTimer, &QTimer::timeout, this, [this]() {
        refreshModel();
    });

    // load quicksettings packages
    auto packages = KPackage::PackageLoader::self()->listPackages(QStringLiteral("KPackage/GenericQML"), "plasma/quicksettings");

    for (auto &metaData : packages) {
        KPackage::Package package = KPackage::PackageLoader::self()->loadPackage("KPackage/GenericQML", QFileInfo(metaData.fileName()).path());
        if (!package.isValid()) {
            qWarning() << "Quick setting package invalid:" << metaData.fileName();
            continue;
        }
        m_validPackages.push_back(new KPluginMetaData{metaData});
    }

    // subscribe to config changes
    connect(m_settings, &MobileShellSettings::enabledQuickSettingsChanged, this, [this]() {
        m_updateTimer->start();
    });
    connect(m_settings, &MobileShellSettings::disabledQuickSettingsChanged, this, [this]() {
        m_updateTimer->start();
    });

    // subscribe to model changes
    connect(m_enabledQSModel, &SavedQuickSettingsModel::dataUpdated, this, [this](QList<KPluginMetaData *> data) -> void {
        m_enabledPackages.clear();
        for (auto metaData : data) {
            m_enabledPackages.push_back(metaData);
        }

        saveModel();
    });
    connect(m_disabledQSModel, &SavedQuickSettingsModel::dataUpdated, this, [this](QList<KPluginMetaData *> data) -> void {
        m_disabledPackages.clear();
        for (auto metaData : data) {
            m_disabledPackages.push_back(metaData);
        }

        saveModel();
    });

    // load
    refreshModel();
}

SavedQuickSettingsModel *SavedQuickSettings::enabledQuickSettingsModel() const
{
    return m_enabledQSModel;
}

SavedQuickSettingsModel *SavedQuickSettings::disabledQuickSettingsModel() const
{
    return m_disabledQSModel;
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
            if (pluginId == metaData->pluginId()) {
                m_enabledPackages.push_back(metaData);
                break;
            }
        }
    }

    // add disabled quick settings in order
    for (const QString &pluginId : disabledQS) {
        for (auto &metaData : m_validPackages) {
            if (pluginId == metaData->pluginId()) {
                m_disabledPackages.push_back(metaData);
                break;
            }
        }
    }

    // add undefined quick settings to the back of enabled quick settings
    for (auto &metaData : m_validPackages) {
        if (!enabledQS.contains(metaData->pluginId()) && !disabledQS.contains(metaData->pluginId())) {
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
        enabledQS.push_back(metaData->pluginId());
    }
    for (auto &metaData : m_disabledPackages) {
        disabledQS.push_back(metaData->pluginId());
    }

    m_settings->setEnabledQuickSettings(enabledQS);
    m_settings->setDisabledQuickSettings(disabledQS);
}
