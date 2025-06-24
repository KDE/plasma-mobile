// SPDX-FileCopyrightText: 2021 Vlad Zahorodnii <vlad.zahorodnii@kde.org>
// SPDX-FileCopyrightText: 2024 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "taskmodel.h"

// KWin
#include <core/output.h>
#include <virtualdesktops.h>
#include <workspace.h>

namespace KWin
{

TaskModel::TaskModel(QObject *parent)
    : QAbstractListModel(parent)
{
    connect(workspace(), &Workspace::windowAdded, this, &TaskModel::handleWindowAdded);
    connect(workspace(), &Workspace::windowRemoved, this, &TaskModel::handleWindowRemoved);
    connect(workspace(), &Workspace::windowActivated, this, &TaskModel::handleActiveWindowChanged);

    auto windows = workspace()->windows();
    const qint64 currentTime = QDateTime::currentMSecsSinceEpoch();

    for (Window *window : std::as_const(windows)) {
        m_windows.push_back({window, currentTime});
        setupWindowConnections(window);
    }
}

void TaskModel::markRoleChanged(Window *window, int role)
{
    int windowIndex = -1;
    for (int i = 0; i < m_windows.size(); ++i) {
        if (m_windows[i].first == window) {
            windowIndex = i;
            break;
        }
    }
    const QModelIndex row = index(windowIndex, 0);
    Q_EMIT dataChanged(row, row, {role});
}

void TaskModel::setupWindowConnections(Window *window)
{
    connect(window, &Window::desktopsChanged, this, [this, window]() {
        markRoleChanged(window, DesktopRole);
    });
    connect(window, &Window::outputChanged, this, [this, window]() {
        markRoleChanged(window, OutputRole);
    });
}

void TaskModel::handleWindowAdded(Window *window)
{
    beginInsertRows(QModelIndex(), m_windows.count(), m_windows.count());
    const qint64 currentTime = QDateTime::currentMSecsSinceEpoch();
    m_windows.append({window, currentTime});
    endInsertRows();

    setupWindowConnections(window);
}

void TaskModel::handleWindowRemoved(Window *window)
{
    int index = -1;
    for (int i = 0; i < m_windows.size(); ++i) {
        if (m_windows[i].first == window) {
            index = i;
            break;
        }
    }
    Q_ASSERT(index != -1);

    beginRemoveRows(QModelIndex(), index, index);
    m_windows.removeAt(index);
    endRemoveRows();
}

QHash<int, QByteArray> TaskModel::roleNames() const
{
    return {
        {Qt::DisplayRole, QByteArrayLiteral("display")},
        {WindowRole, QByteArrayLiteral("window")},
        {OutputRole, QByteArrayLiteral("output")},
        {DesktopRole, QByteArrayLiteral("desktop")},
    };
}

QVariant TaskModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() < 0 || index.row() >= m_windows.count()) {
        return QVariant();
    }

    Window *window = m_windows[index.row()].first;
    qint64 lastActivated = m_windows[index.row()].second;
    switch (role) {
    case Qt::DisplayRole:
    case WindowRole:
        return QVariant::fromValue(window);
    case OutputRole:
        return QVariant::fromValue(window->output());
    case DesktopRole:
        return QVariant::fromValue(window->desktops());
    case LastActivatedRole:
        return lastActivated;
    default:
        return QVariant();
    }
}

int TaskModel::rowCount(const QModelIndex &parent) const
{
    return parent.isValid() ? 0 : m_windows.count();
}

void TaskModel::handleActiveWindowChanged()
{
    Window *window = workspace()->activeWindow();
    if (!window) {
        return;
    }

    const qint64 currentTime = QDateTime::currentMSecsSinceEpoch();
    for (int i = 0; i < m_windows.size(); ++i) {
        if (m_windows[i].first == window) {
            m_windows[i] = {window, currentTime};
            Q_EMIT dataChanged(index(i, 0), index(i, 0), {TaskModel::LastActivatedRole});
        }
    }
}

} // namespace KWin
