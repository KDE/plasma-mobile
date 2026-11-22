// SPDX-FileCopyrightText: 2024 Micah Stanley <stanleymicah@proton.me>
// SPDX-FileCopyrightText: 2024-2025 Luis Büchi <luis.buechi@kdemail.net>
// SPDX-FileCopyrightText: 2026 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "tasknavigator.h"

#include <algorithm>
#include <cmath>

// how much the task list resists shrinking when dragged further up than the opened position,
// 1 would match the y position one to one
static constexpr qreal OVER_DRAG_SCALE_RESISTANCE = 0.5;

// how far up from the opened position (relative to it) the task list follows the finger directly,
// before it starts resisting
static constexpr qreal OVER_DRAG_DIRECT_TRACKING = 0.2;

TaskNavigator::TaskNavigator(QObject *parent)
    : QObject{parent}
{
    connect(this, &TaskNavigator::yPositionChanged, this, &TaskNavigator::scaleChanged);
    connect(this, &TaskNavigator::originChanged, this, &TaskNavigator::scaleChanged);
    connect(this, &TaskNavigator::layoutChanged, this, &TaskNavigator::scaleChanged);
}

TaskLayout *TaskNavigator::layout() const
{
    return m_layout;
}

void TaskNavigator::setLayout(TaskLayout *layout)
{
    if (m_layout == layout) {
        return;
    }
    if (m_layout) {
        disconnect(m_layout, nullptr, this, nullptr);
    }
    m_layout = layout;
    if (m_layout) {
        // the sizes of the tasks change the scale
        connect(m_layout, &TaskLayout::layoutChanged, this, &TaskNavigator::scaleChanged);
        m_layout->setScrollPosition(m_xPosition);
    }
    Q_EMIT layoutChanged();
}

qreal TaskNavigator::openedYPosition() const
{
    return m_openedYPosition;
}

void TaskNavigator::setOpenedYPosition(qreal openedYPosition)
{
    if (m_openedYPosition != openedYPosition) {
        m_openedYPosition = openedYPosition;
        Q_EMIT scaleChanged();
    }
}

qreal TaskNavigator::closingScale() const
{
    return m_closingScale;
}

void TaskNavigator::setClosingScale(qreal closingScale)
{
    if (m_closingScale != closingScale) {
        m_closingScale = closingScale;
        Q_EMIT scaleChanged();
    }
}

bool TaskNavigator::tracking() const
{
    return m_tracking;
}

void TaskNavigator::setTracking(bool tracking)
{
    if (m_tracking != tracking) {
        m_tracking = tracking;
        Q_EMIT trackingChanged();
    }
}

bool TaskNavigator::taskDrawerOpened() const
{
    return m_taskDrawerOpened;
}

void TaskNavigator::setTaskDrawerOpened(bool taskDrawerOpened)
{
    if (m_taskDrawerOpened != taskDrawerOpened) {
        m_taskDrawerOpened = taskDrawerOpened;
        Q_EMIT originChanged();
    }
}

bool TaskNavigator::startedInApp() const
{
    return m_startedInApp;
}

void TaskNavigator::setStartedInApp(bool startedInApp)
{
    if (m_startedInApp != startedInApp) {
        m_startedInApp = startedInApp;
        Q_EMIT originChanged();
    }
}

bool TaskNavigator::onHomeScreen() const
{
    return !m_startedInApp && !m_taskDrawerOpened;
}

qreal TaskNavigator::xPosition() const
{
    return m_xPosition;
}

void TaskNavigator::setXPosition(qreal xPosition)
{
    if (m_xPosition != xPosition) {
        m_xPosition = xPosition;
        if (m_layout) {
            m_layout->setScrollPosition(xPosition);
        }
        Q_EMIT xPositionChanged();
        updateCurrentTask();
    }
}

qreal TaskNavigator::yPosition() const
{
    return m_yPosition;
}

void TaskNavigator::setYPosition(qreal yPosition)
{
    if (m_yPosition != yPosition) {
        m_yPosition = yPosition;
        Q_EMIT yPositionChanged();
    }
}

int TaskNavigator::currentTaskIndex() const
{
    return m_currentTaskIndex;
}

void TaskNavigator::setCurrentTaskIndex(int index)
{
    if (m_currentTaskIndex != index) {
        m_currentTaskIndex = index;
        Q_EMIT currentTaskIndexChanged();
    }
}

int TaskNavigator::initialTaskIndex() const
{
    return m_initialTaskIndex;
}

void TaskNavigator::setInitialTaskIndex(int index)
{
    if (m_initialTaskIndex != index) {
        m_initialTaskIndex = index;
        Q_EMIT initialTaskIndexChanged();
    }
}

int TaskNavigator::displayedTaskIndex() const
{
    return m_displayedTaskIndex;
}

void TaskNavigator::setDisplayedTaskIndex(int index)
{
    if (m_displayedTaskIndex != index) {
        m_displayedTaskIndex = index;
        Q_EMIT displayedTaskIndexChanged();
    }
}

int TaskNavigator::count() const
{
    return m_layout ? m_layout->count() : 0;
}

qreal TaskNavigator::scrollPositionForTask(int index) const
{
    return m_layout ? m_layout->scrollPositionForTask(index) : 0;
}

int TaskNavigator::clampIndex(int index) const
{
    return std::max(0, std::min(count() - 1, index));
}

void TaskNavigator::start(int index)
{
    setInitialTaskIndex(index);
    setCurrentTaskIndex(index);
    setDisplayedTaskIndex(index);
    goToTask(index);
}

void TaskNavigator::beginGesture()
{
    setDisplayedTaskIndex(m_currentTaskIndex);
}

void TaskNavigator::goToTask(int index)
{
    setXPosition(scrollPositionForTask(index));
}

void TaskNavigator::followTouch(qreal touchX, qreal touchY)
{
    // from an app the task fills the screen at the start, otherwise the task drawer is already opened
    setYPosition(std::abs(touchY) + (m_taskDrawerOpened || !m_startedInApp ? m_openedYPosition : 0));

    // the tasks follow the finger sideways (at the scale they are shown at, which follows the y position),
    // except on the home screen, where the task drawer moves instead
    qreal x = scrollPositionForTask(m_initialTaskIndex);
    if (!onHomeScreen() && scale() > 0) {
        x -= touchX / scale();
    }
    setXPosition(x);
}

bool TaskNavigator::overDragged() const
{
    return m_yPosition > m_openedYPosition;
}

qreal TaskNavigator::overDragOffset() const
{
    if (!overDragged()) {
        return 0;
    }
    // follow the finger directly at first
    const qreal directTracking = m_openedYPosition * OVER_DRAG_DIRECT_TRACKING;
    if (m_yPosition < m_openedYPosition + directTracking) {
        return m_yPosition - m_openedYPosition;
    }
    // but more reluctantly the further up it goes: 1-2.3^(-progress) asymptotically approaches 1
    const qreal progress = (m_yPosition - directTracking - m_openedYPosition) / m_openedYPosition;
    return (1 - std::pow(2.3, -progress)) * m_openedYPosition + directTracking;
}

qreal TaskNavigator::scale() const
{
    // closing overrides the scale, for a smoother closing animation
    if (m_closingScale < 1 && (m_startedInApp || m_taskDrawerOpened)) {
        return m_closingScale;
    }
    if (!m_layout || m_layout->previewScale() <= 0) {
        return 1;
    }

    // the scale at which a task fills the screen
    const qreal maxScale = 1 / m_layout->previewScale();
    if (m_openedYPosition <= 0) {
        return maxScale;
    }
    // shrinks while opening, and further (by the layout's range) when dragged further up than the opened position
    const qreal subtract = (maxScale - 1) * (std::min(m_yPosition, m_openedYPosition) / m_openedYPosition)
        + m_layout->overDragScaleRange() * overDragOffset() * OVER_DRAG_SCALE_RESISTANCE / m_openedYPosition;
    return std::min(maxScale, maxScale - subtract);
}

qreal TaskNavigator::openProgress() const
{
    if (!m_layout || m_layout->previewScale() <= 0 || m_layout->previewScale() >= 1) {
        return 1;
    }
    const qreal maxScale = 1 / m_layout->previewScale();
    return std::clamp((maxScale - scale()) / (maxScale - 1), 0.0, 1.0);
}

void TaskNavigator::updateCurrentTask()
{
    if (m_tracking && m_layout) {
        setCurrentTaskIndex(m_layout->taskAt(m_xPosition, m_currentTaskIndex));
    }
}

void TaskNavigator::keepPosition(TaskLayout *from, TaskLayout *to)
{
    if (!from || !to) {
        return;
    }
    const qreal offset = m_xPosition - from->scrollPositionForTask(m_currentTaskIndex);
    const qreal stepRatio = (to->taskWidth() + to->spacing()) / (from->taskWidth() + from->spacing());
    setXPosition(to->scrollPositionForTask(m_currentTaskIndex) + offset * stepRatio);
}

void TaskNavigator::restInLayout()
{
    if (m_layout) {
        setXPosition(m_layout->restingScrollPosition(m_xPosition, m_currentTaskIndex));
    }
    updateCurrentTask();
}

void TaskNavigator::removeTasks(int first, int last, int count)
{
    int index = m_currentTaskIndex;
    if (last < index) {
        index -= last - first + 1;
    } else if (first <= index) {
        index = first;
    }
    setCurrentTaskIndex(std::max(0, std::min(index, count - 1)));
}

int TaskNavigator::nearestTask() const
{
    if (!m_layout || m_xPosition > scrollPositionForTask(m_currentTaskIndex)) {
        return m_currentTaskIndex;
    }
    return std::min(count() - 1, m_layout->taskAt(m_xPosition, m_currentTaskIndex));
}

int TaskNavigator::snapTarget(bool movingRight) const
{
    // the next column in the direction the list was moving, or back to the current task
    const int rows = m_layout ? m_layout->rows() : 1;
    const bool towardsNewer = m_xPosition > scrollPositionForTask(m_currentTaskIndex);
    if (towardsNewer) {
        return movingRight ? m_currentTaskIndex : std::max(0, m_currentTaskIndex - rows);
    }
    return movingRight ? std::min(count() - 1, m_currentTaskIndex + rows) : m_currentTaskIndex;
}

int TaskNavigator::scrubTarget(qreal touchX, qreal scrubDistance) const
{
    if (scrubDistance <= 0) {
        return m_currentTaskIndex;
    }
    // from the home screen, the first step goes to the most recent task
    const int steps = std::floor(touchX / scrubDistance);
    return clampIndex(m_initialTaskIndex + steps - (m_startedInApp ? 0 : 1));
}

int TaskNavigator::quickSwitchTarget(int direction) const
{
    // flicking to the right goes to the app on the left (the next one), and the other way around.
    // On the home screen, the current task is the most recent one, which isn't shown yet
    const int index = onHomeScreen() ? m_currentTaskIndex : m_currentTaskIndex + direction;
    if (direction == 0 || index < 0 || index >= count()) {
        return -1;
    }
    return index;
}
