// SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

#include "savedquicksettingsmodel.h"

SavedQuickSettingsModel::SavedQuickSettingsModel(QObject *parent)
    : QAbstractListModel{parent}
{
}

QVariant SavedQuickSettingsModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() >= m_data.count()) {
        return QVariant();
    }

    if (role == NameRole) {
        return m_data[index.row()].name();
    } else if (role == IconRole) {
        return m_data[index.row()].iconName();
    } else if (role == IdRole) {
        return m_data[index.row()].pluginId();
    }
    return QVariant();
}

int SavedQuickSettingsModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_data.count();
}

QHash<int, QByteArray> SavedQuickSettingsModel::roleNames() const
{
    return {{NameRole, "name"}, {IdRole, "id"}, {IconRole, "icon"}};
}

void SavedQuickSettingsModel::moveRow(int oldIndex, int newIndex)
{
    if (oldIndex < 0 || oldIndex >= m_data.count() || newIndex < 0 || newIndex >= m_data.count()) {
        return;
    }

    Q_EMIT beginMoveRows(QModelIndex(), oldIndex, oldIndex, QModelIndex(), newIndex + (oldIndex < newIndex ? 1 : 0));
    std::iter_swap(m_data.begin() + oldIndex, m_data.begin() + newIndex);
    Q_EMIT endMoveRows();

    Q_EMIT dataUpdated(m_data);
}

void SavedQuickSettingsModel::insertRow(KPluginMetaData metaData, int index)
{
    beginInsertRows(QModelIndex(), index, index);
    m_data.insert(index, metaData);
    endInsertRows();

    Q_EMIT dataUpdated(m_data);
}

KPluginMetaData SavedQuickSettingsModel::takeRow(int index)
{
    if (index < 0 || index >= m_data.size()) {
        return {};
    }

    Q_EMIT beginRemoveRows(QModelIndex(), index, index);
    KPluginMetaData tmp = m_data.takeAt(index);
    Q_EMIT endRemoveRows();

    Q_EMIT dataUpdated(m_data);

    return tmp;
}

void SavedQuickSettingsModel::removeRow(int index)
{
    if (index < 0 || index >= m_data.size()) {
        return;
    }

    Q_EMIT beginRemoveRows(QModelIndex(), index, index);
    m_data.erase(m_data.begin() + index);
    Q_EMIT endRemoveRows();

    Q_EMIT dataUpdated(m_data);
}

QList<KPluginMetaData> SavedQuickSettingsModel::list() const
{
    return m_data;
}

void SavedQuickSettingsModel::updateData(QList<KPluginMetaData> data)
{
    Q_EMIT beginResetModel();

    m_data.clear();
    for (auto metaData : data) {
        m_data.push_back(metaData);
    }

    Q_EMIT endResetModel();

    Q_EMIT dataUpdated(m_data);
}
