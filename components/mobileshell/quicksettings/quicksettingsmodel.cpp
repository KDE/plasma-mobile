/*
 *   SPDX-FileCopyrightText: 2021 Aleix Pol Gonzalez <aleixpol@kde.org>
 *   SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
 *
 *   SPDX-License-Identifier: LGPL-2.0-or-later
 */

#include "quicksettingsmodel.h"

#include <KPackage/PackageLoader>

#include <QFileInfo>
#include <QQmlComponent>
#include <QQmlEngine>

QuickSettingsModel::QuickSettingsModel(QObject *parent)
    : QAbstractListModel{parent}
    , m_savedQuickSettings{new SavedQuickSettings{this}}
{
    connect(m_savedQuickSettings->enabledQuickSettingsModel(), &SavedQuickSettingsModel::dataUpdated, this, [this]() {
        loadQuickSettings();
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
    Q_UNUSED(parent);
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

    QQmlEngine *engine = qmlEngine(this);
    QQmlComponent *c = new QQmlComponent(engine, this);

    // loop through enabled quick settings metadata
    for (const auto &metaData : m_savedQuickSettings->enabledQuickSettingsModel()->list()) {
        // load kpackage
        KPackage::Package package = KPackage::PackageLoader::self()->loadPackage("KPackage/GenericQML", QFileInfo(metaData->fileName()).path());
        if (!package.isValid()) {
            continue;
        }

        // load QML from kpackage
        c->loadUrl(package.fileUrl("mainscript"), QQmlComponent::PreferSynchronous);

        auto created = c->create(engine->rootContext());
        auto createdSetting = qobject_cast<QuickSetting *>(created);

        // print errors if there were issues loading
        if (!createdSetting) {
            qWarning() << "Unable to load quick setting element:" << created;
            for (auto error : c->errors()) {
                qWarning() << error;
            }
            delete created;
        } else {
            if (createdSetting->isAvailable()) {
                m_quickSettings.push_back(createdSetting);
            }
            connect(createdSetting, &QuickSetting::availableChanged, this, &QuickSettingsModel::availabilityChanged);
        }
    }

    delete c;

    endResetModel();
    Q_EMIT countChanged();
}

void QuickSettingsModel::availabilityChanged()
{
    auto setting = qobject_cast<QuickSetting *>(sender());

    if (setting->isAvailable()) {
        if (!m_quickSettings.contains(setting)) {
            auto idx = m_quickSettings.count();
            beginInsertRows({}, idx, idx);
            m_quickSettings.append(setting);
            endInsertRows();
        }
    } else {
        auto idx = m_quickSettings.indexOf(setting);
        if (idx >= 0) {
            beginRemoveRows({}, idx, idx);
            m_quickSettings.removeAt(idx);
            endRemoveRows();
        }
    }

    Q_EMIT countChanged();
}
