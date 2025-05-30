// SPDX-FileCopyrightText: 2021 Vlad Zahorodnii <vlad.zahorodnii@kde.org>
// SPDX-FileCopyrightText: 2024 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "taskfiltermodel.h"

// KWin
#include <activities.h>
#include <config-kwin.h>
#include <core/output.h>
#include <core/outputbackend.h>
#include <virtualdesktops.h>
#include <workspace.h>

namespace KWin
{

TaskFilterModel::TaskFilterModel(QObject *parent)
    : QSortFilterProxyModel(parent)
{
    setSortRole(TaskModel::LastActivatedRole);

    // Don't auto-sort, because this model is loaded at runtime during the task switcher
    // -> We don't want to re-sort while the task switcher is open
    setDynamicSortFilter(false);
}

TaskModel *TaskFilterModel::windowModel() const
{
    return m_taskModel;
}

void TaskFilterModel::setWindowModel(TaskModel *taskModel)
{
    if (taskModel == m_taskModel) {
        return;
    }
    m_taskModel = taskModel;
    setSourceModel(m_taskModel);
    Q_EMIT windowModelChanged();

    // Sort after source model is set
    sort(0);
}

QString TaskFilterModel::screenName() const
{
    return m_output ? m_output->name() : QString();
}

void TaskFilterModel::setScreenName(const QString &screen)
{
    Output *output = kwinApp()->outputBackend()->findOutput(screen);
    if (m_output != output) {
        m_output = output;
        Q_EMIT screenNameChanged();
        invalidateFilter();
    }
}

bool TaskFilterModel::filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const
{
    if (!m_taskModel) {
        return false;
    }
    const QModelIndex index = m_taskModel->index(sourceRow, 0, sourceParent);
    if (!index.isValid()) {
        return false;
    }
    const QVariant data = index.data();
    if (!data.isValid()) {
        // an invalid QVariant is valid data
        return true;
    }

    Window *window = qvariant_cast<Window *>(data);
    if (!window || !window->isClient()) {
        return false;
    }

#if KWIN_BUILD_ACTIVITIES 
    // Filter by same activity
    auto activity = Workspace::self()->activities()->current();
    if (!window->isOnActivity(activity)) {
        return false;
    }
#endif

    // Filter by same desktop
    auto desktop = VirtualDesktopManager::self()->currentDesktop();
    if (!window->isOnDesktop(desktop)) {
        return false;
    }

    // Filter by same screen
    if (window->output() != m_output) {
        return false;
    }

    if (window->isDock()) {
        return false;
    }
    if (window->isDesktop()) {
        return false;
    }
    if (window->isNotification()) {
        return false;
    }
    if (window->isCriticalNotification()) {
        return false;
    }
    if (window->skipSwitcher()) {
        return false;
    }

    return true;
}

bool TaskFilterModel::lessThan(const QModelIndex &left, const QModelIndex &right) const
{
    qint64 leftLastActivated = qvariant_cast<qint64>(left.data(TaskModel::LastActivatedRole));
    qint64 rightLastActivated = qvariant_cast<qint64>(right.data(TaskModel::LastActivatedRole));

    // Sort order: oldest -> newest
    // - For ties: alphabetically

    if (leftLastActivated != rightLastActivated) {
        return leftLastActivated > rightLastActivated;
    } else {
        // If leftLastActivated == rightLastActivated, sort alphabetically by window title
        Window *leftWindow = qvariant_cast<Window *>(left.data(TaskModel::WindowRole));
        Window *rightWindow = qvariant_cast<Window *>(right.data(TaskModel::WindowRole));

        if (!leftWindow || !rightWindow) {
            return true;
        }

        return leftWindow->caption() < rightWindow->caption();
    }
}

} // namespace KWin
