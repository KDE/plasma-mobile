/*
 *   SPDX-FileCopyrightText: 2021 Aleix Pol Gonzalez <aleixpol@kde.org>
 *   SPDX-FileCopyrightText: 2022-2024 Devin Lin <devin@kde.org>
 *
 *   SPDX-License-Identifier: LGPL-2.0-or-later
 */

#include "quicksettingsmodel.h"

#include <KPackage/PackageLoader>

#include <KLocalizedContext>
#include <QFileInfo>
#include <QQmlContext>
#include <QQmlEngine>

QuickSettingsModel::QuickSettingsModel(QObject *parent)
    : QAbstractListModel{parent}
    , m_savedQuickSettings{new SavedQuickSettings{this}}
{
    // Listen to events to enabled quicksettings, and update accordingly
    connect(m_savedQuickSettings->enabledQuickSettingsModel(), &SavedQuickSettingsModel::modelReset, this, [this]() {
        loadQuickSettings();
    });
    connect(m_savedQuickSettings->enabledQuickSettingsModel(), &SavedQuickSettingsModel::rowsInserted, this, [this](const QModelIndex &, int first, int last) {
        for (int i = first; i <= last; ++i) {
            KPluginMetaData metaData = m_savedQuickSettings->enabledQuickSettingsModel()->takeRow(i);
            loadQuickSetting(metaData, true);
        }
    });
    connect(m_savedQuickSettings->enabledQuickSettingsModel(),
            &SavedQuickSettingsModel::rowsAboutToBeRemoved,
            this,
            [this](const QModelIndex &, int first, int last) {
                for (int i = first; i <= last; ++i) {
                    KPluginMetaData metaData = m_savedQuickSettings->enabledQuickSettingsModel()->takeRow(i);
                    auto index = m_quickSettingsMetaData.indexOf(metaData);
                    removeQuickSetting(index);
                }
            });
    connect(m_savedQuickSettings->enabledQuickSettingsModel(),
            &SavedQuickSettingsModel::rowsMoved,
            this,
            [this](const QModelIndex &, int sourceStart, int sourceEnd, const QModelIndex &, int) {
                for (int i = sourceStart; i <= sourceEnd; ++i) {
                    KPluginMetaData metaData = m_savedQuickSettings->enabledQuickSettingsModel()->takeRow(i);
                    auto index = m_quickSettingsMetaData.indexOf(metaData);
                    removeQuickSetting(index);
                    loadQuickSetting(metaData, true);
                }
            });
}

void QuickSettingsModel::classBegin()
{
    m_loaded = true;
    loadQuickSettings();
}

void QuickSettingsModel::componentComplete()
{
}

QHash<int, QByteArray> QuickSettingsModel::roleNames() const
{
    return {{Qt::UserRole, "modelData"}};
}

int QuickSettingsModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_quickSettings.size();
}

QVariant QuickSettingsModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() >= rowCount({}) || role != Qt::UserRole) {
        return {};
    }

    QObject *obj = m_quickSettings[index.row()];
    return QVariant::fromValue<QObject *>(obj);
}

void QuickSettingsModel::loadQuickSettings()
{
    if (!m_loaded) {
        return;
    }

    beginResetModel();

    for (auto *quickSetting : m_quickSettings) {
        quickSetting->deleteLater();
    }
    m_quickSettings.clear();
    m_quickSettingsMetaData.clear();

    // Loop through enabled quick settings and start loading them
    for (const auto &metaData : m_savedQuickSettings->enabledQuickSettingsModel()->list()) {
        // false - Ensure row insertion signals aren't emitted (since we are resetting the model)
        loadQuickSetting(metaData, false);
    }

    endResetModel();
    Q_EMIT countChanged();
}

void QuickSettingsModel::loadQuickSetting(KPluginMetaData metaData, bool emitInsertSignal)
{
    if (!m_loaded) {
        return;
    }

    // Load KPackage
    const KPackage::Package package = KPackage::PackageLoader::self()->loadPackage("KPackage/GenericQML", QFileInfo(metaData.fileName()).path());
    if (!package.isValid()) {
        return;
    }

    // Create translation context
    QQmlEngine *engine = qmlEngine(this);
    KLocalizedContext *i18nContext = new KLocalizedContext(engine);
    i18nContext->setTranslationDomain(QLatin1String("plasma_") + metaData.pluginId());
    engine->rootContext()->setContextObject(i18nContext);

    QQmlComponent *component = new QQmlComponent(engine, this);

    // Load QML from KPackage async
    component->loadUrl(package.fileUrl("mainscript"), QQmlComponent::Asynchronous);

    if (component->isLoading()) {
        // Listen to load completion
        connect(component, &QQmlComponent::statusChanged, this, [this, metaData, component, engine]() {
            afterQuickSettingLoad(engine, metaData, component, true);
        });
    } else {
        // Only emit insertion signal if we aren't resetting the model
        afterQuickSettingLoad(engine, metaData, component, emitInsertSignal);
    }
}

void QuickSettingsModel::removeQuickSetting(int index)
{
    if (index >= 0) {
        beginRemoveRows({}, index, 0);
        m_quickSettings.removeAt(index);
        m_quickSettingsMetaData.removeAt(index);
        endRemoveRows();
        Q_EMIT countChanged();
    }
}

void QuickSettingsModel::afterQuickSettingLoad(QQmlEngine *engine, KPluginMetaData metaData, QQmlComponent *component, bool emitInsertSignal)
{
    // Create quicksetting component
    QObject *object = component->create(engine->rootContext());
    if (!object) {
        qWarning() << "Unable to load quick setting element:" << metaData.pluginId();
        component->deleteLater();
        return;
    }

    if (component->isError()) {
        // Print errors
        qWarning() << "Unable to load quick setting element:" << metaData.pluginId();
        for (auto error : component->errors()) {
            qWarning() << error;
        }

        component->deleteLater();
    } else if (component->isReady()) {
        component->deleteLater();

        auto createdSetting = qobject_cast<QuickSetting *>(object);

        // Connect availability signal to insert/remove quicksetting into model
        connect(createdSetting, &QuickSetting::availableChanged, this, [this, metaData, createdSetting]() {
            availabilityChanged(metaData, createdSetting);
        });

        // Add quicksetting to model if available
        if (createdSetting->isAvailable()) {
            insertQuickSettingToModel(metaData, createdSetting, emitInsertSignal);
        }
    }
}

void QuickSettingsModel::insertQuickSettingToModel(KPluginMetaData metaData, QuickSetting *quickSetting, bool emitInsertSignal)
{
    // Insert into correct position based on the saved quick settings order
    int insertIndex = 0;
    auto list = m_savedQuickSettings->enabledQuickSettingsModel()->list();
    for (int i = 0; i < list.size(); ++i) {
        if (insertIndex >= m_quickSettingsMetaData.size()) {
            break;
        }

        if (list[i].pluginId() == m_quickSettingsMetaData[insertIndex].pluginId()) {
            if (metaData.pluginId() == list[i].pluginId()) {
                break;
            }
            ++insertIndex;
        }
    }

    if (emitInsertSignal) {
        beginInsertRows({}, insertIndex, insertIndex);
    }

    m_quickSettings.insert(insertIndex, quickSetting);
    m_quickSettingsMetaData.insert(insertIndex, metaData);

    if (emitInsertSignal) {
        endInsertRows();
    }
    Q_EMIT countChanged();
}

void QuickSettingsModel::availabilityChanged(KPluginMetaData metaData, QuickSetting *quickSetting)
{
    if (quickSetting->isAvailable()) {
        if (!m_quickSettings.contains(quickSetting)) {
            insertQuickSettingToModel(metaData, quickSetting, true);
        }
    } else {
        auto idx = m_quickSettings.indexOf(quickSetting);
        removeQuickSetting(idx);
    }
}
