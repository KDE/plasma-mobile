/*
 *   SPDX-FileCopyrightText: 2021 Aleix Pol Gonzalez <aleixpol@kde.org>
 *
 *   SPDX-License-Identifier: LGPL-2.0-or-later
 */

#include "quicksettingsmodel.h"

QuickSettingsModel::QuickSettingsModel(QObject *parent)
    : QAbstractListModel(parent)
{
}

QHash<int, QByteArray> QuickSettingsModel::roleNames() const
{
    return {{Qt::UserRole, "modelData"}};
}

QQmlListProperty<QuickSetting> QuickSettingsModel::children()
{
    return QQmlListProperty<QuickSetting>(this, &m_children);
}

int QuickSettingsModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid())
        return 0;

    return m_children.count();
}

QVariant QuickSettingsModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() >= m_children.count() || role != Qt::UserRole) {
        return {};
    }

    return QVariant::fromValue<QObject *>(m_children[index.row()]);
}

////////////////////////

QuickSetting::QuickSetting(QObject *parent)
    : QObject(parent)
{
}

void QuickSetting::setEnabled(bool enabled)
{
    if (m_enabled == enabled)
        return;

    m_enabled = enabled;
    Q_EMIT enabledChanged(enabled);
}

void QuickSetting::setSettingsCommand(const QString &settingsCommand)
{
    if (m_settingsCommand == settingsCommand)
        return;

    m_settingsCommand = settingsCommand;
    Q_EMIT settingsCommandChanged(settingsCommand);
}

void QuickSetting::setIconName(const QString &iconName)
{
    if (m_iconName == iconName)
        return;

    m_iconName = iconName;
    Q_EMIT iconNameChanged(iconName);
}

void QuickSetting::setText(const QString &text)
{
    if (m_text == text)
        return;

    m_text = text;
    Q_EMIT textChanged(text);
}

QQmlListProperty<QObject> QuickSetting::children()
{
    return QQmlListProperty<QObject>(this, &m_children);
}

void QuickSettingsModel::include(QuickSetting *item)
{
    beginInsertRows({}, m_children.count(), m_children.count());
    m_children.append(item);
    endInsertRows();
}
