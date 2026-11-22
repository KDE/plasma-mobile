// SPDX-FileCopyrightText: 2024 Micah Stanley <stanleymicah@proton.me>
// SPDX-FileCopyrightText: 2024-2025 Luis Büchi <luis.buechi@kdemail.net>
// SPDX-FileCopyrightText: 2026 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "tasklayout.h"

#include <algorithm>
#include <cmath>

// rounds like JavaScript's Math.round(), halfway values go towards +infinity
static qreal roundHalfUp(qreal value)
{
    return std::floor(value + 0.5);
}

TaskLayout::TaskLayout(QObject *parent)
    : QObject{parent}
{
    connect(this, &TaskLayout::layoutChanged, this, &TaskLayout::displayedScrollPositionChanged);
    connect(this, &TaskLayout::scrollPositionChanged, this, &TaskLayout::displayedScrollPositionChanged);
}

int TaskLayout::count() const
{
    return m_count;
}

void TaskLayout::setCount(int count)
{
    if (m_count != count) {
        m_count = count;
        Q_EMIT layoutChanged();
    }
}

QSizeF TaskLayout::windowSize() const
{
    return m_windowSize;
}

void TaskLayout::setWindowSize(const QSizeF &windowSize)
{
    if (m_windowSize != windowSize) {
        m_windowSize = windowSize;
        Q_EMIT layoutChanged();
    }
}

qreal TaskLayout::spacing() const
{
    return m_spacing;
}

void TaskLayout::setSpacing(qreal spacing)
{
    if (m_spacing != spacing) {
        m_spacing = spacing;
        Q_EMIT layoutChanged();
    }
}

qreal TaskLayout::headerHeight() const
{
    return m_headerHeight;
}

void TaskLayout::setHeaderHeight(qreal headerHeight)
{
    if (m_headerHeight != headerHeight) {
        m_headerHeight = headerHeight;
        Q_EMIT layoutChanged();
    }
}

qreal TaskLayout::scrollPosition() const
{
    return m_scrollPosition;
}

void TaskLayout::setScrollPosition(qreal scrollPosition)
{
    if (m_scrollPosition != scrollPosition) {
        m_scrollPosition = scrollPosition;
        Q_EMIT scrollPositionChanged();
    }
}

int TaskLayout::columnCount() const
{
    return std::ceil(qreal(m_count) / rows());
}

qreal TaskLayout::taskWidth() const
{
    return m_windowSize.width() * previewScale();
}

qreal TaskLayout::taskHeight() const
{
    return m_windowSize.height() * previewScale() + m_headerHeight;
}

qreal TaskLayout::contentWidth() const
{
    return std::max(0, columnCount() - 1) * step() + taskWidth();
}

qreal TaskLayout::rowsOverhang() const
{
    return (rows() - 1) / 2.0 * (taskHeight() + m_spacing);
}

qreal TaskLayout::step() const
{
    return taskWidth() + m_spacing;
}

int TaskLayout::columnOf(int index) const
{
    return std::floor(qreal(index) / rows());
}

int TaskLayout::rowOf(int index) const
{
    return index % rows();
}

qreal TaskLayout::taskX(int index) const
{
    return -columnOf(index) * step();
}

qreal TaskLayout::rowOffset(int index) const
{
    return (rowOf(index) - (rows() - 1) / 2.0) * (taskHeight() + m_spacing);
}

int TaskLayout::taskAt(qreal scrollPosition, int currentIndex) const
{
    const int column = roundHalfUp(columnAt(scrollPosition));
    const int index = column * rows() + rowOf(currentIndex);
    return std::max(0, std::min(m_count - 1, index));
}

qreal TaskLayout::clampScroll(qreal scrollPosition) const
{
    return std::max(scrollMinimum(), std::min(scrollMaximum(), scrollPosition));
}

qreal TaskLayout::displayedScrollPosition() const
{
    const qreal clamped = clampScroll(scrollPosition());
    const qreal overscroll = scrollPosition() - clamped;
    // rubber band: starts at about half the finger speed, never further than the limit
    const qreal limit = windowSize().width() / 4;
    if (overscroll == 0 || limit <= 0) {
        return clamped;
    }
    const qreal resisted = limit * (1 - 1 / (std::abs(overscroll) * 0.55 / limit + 1));
    return clamped + std::copysign(resisted, overscroll);
}

// CarouselTaskLayout

int CarouselTaskLayout::rows() const
{
    return 1;
}

qreal CarouselTaskLayout::previewScale() const
{
    // large enough for the task to be recognizable, while showing the adjacent tasks on the sides
    return 0.6;
}

qreal CarouselTaskLayout::overDragScaleRange() const
{
    // shrinks at the same rate as while opening
    return 1 / previewScale() - 1;
}

qreal CarouselTaskLayout::scrollMinimum() const
{
    return count() > 0 ? taskX(count() - 1) : 0;
}

qreal CarouselTaskLayout::scrollMaximum() const
{
    return 0;
}

bool CarouselTaskLayout::zoomsIntoTask() const
{
    return true;
}

qreal CarouselTaskLayout::scrollPositionForTask(int index) const
{
    return taskX(index);
}

qreal CarouselTaskLayout::restingScrollPosition(qreal scrollPosition, int currentIndex) const
{
    Q_UNUSED(scrollPosition)
    return scrollPositionForTask(currentIndex);
}

qreal CarouselTaskLayout::columnAt(qreal scrollPosition) const
{
    return -scrollPosition / step();
}

// ~~ GridTaskLayout ~~

// number of rows
static constexpr int GRID_ROWS = 2;
// portion of the window height used by the rows
static constexpr qreal GRID_HEIGHT_FACTOR = 0.78;
// the grid tasks are much smaller than the window, so the over drag shrinking must not depend on
// their scale like in the carousel, otherwise the tasks quickly disappear. This is similar to the carousel on a phone.
static constexpr qreal GRID_OVER_DRAG_SCALE_RANGE = 0.6;

int GridTaskLayout::rows() const
{
    return GRID_ROWS;
}

qreal GridTaskLayout::previewScale() const
{
    const qreal windowHeight = windowSize().height();
    if (windowHeight <= 0) {
        return 0.1;
    }
    // fit the rows of tasks into a portion of the height
    const qreal previewHeight = (windowHeight * GRID_HEIGHT_FACTOR - (rows() - 1) * spacing()) / rows() - headerHeight();
    return std::max(0.1, previewHeight / windowHeight);
}

qreal GridTaskLayout::overDragScaleRange() const
{
    return GRID_OVER_DRAG_SCALE_RANGE;
}

bool GridTaskLayout::contentFits() const
{
    return contentWidth() <= windowSize().width() - 2 * spacing();
}

qreal GridTaskLayout::scrollMaximum() const
{
    // the most recent column is on the right edge
    if (contentFits()) {
        return (taskWidth() - contentWidth()) / 2;
    }
    return taskWidth() / 2 + spacing() - windowSize().width() / 2;
}

qreal GridTaskLayout::scrollMinimum() const
{
    // the oldest column is on the left edge
    if (contentFits()) {
        return scrollMaximum();
    }
    return windowSize().width() / 2 + taskWidth() / 2 - spacing() - contentWidth();
}

bool GridTaskLayout::zoomsIntoTask() const
{
    return false;
}

qreal GridTaskLayout::scrollPositionForTask(int index) const
{
    return clampScroll(scrollMaximum() - columnOf(index) * step());
}

qreal GridTaskLayout::restingScrollPosition(qreal scrollPosition, int currentIndex) const
{
    Q_UNUSED(currentIndex)
    return clampScroll(scrollPosition);
}

qreal GridTaskLayout::columnAt(qreal scrollPosition) const
{
    return (scrollMaximum() - scrollPosition) / step();
}

// ~~ TaskPlacement ~~

TaskPlacement::TaskPlacement(QObject *parent)
    : QObject{parent}
{
    connect(this, &TaskPlacement::layoutChanged, this, &TaskPlacement::placementChanged);
    connect(this, &TaskPlacement::indexChanged, this, &TaskPlacement::placementChanged);
}

TaskLayout *TaskPlacement::layout() const
{
    return m_layout;
}

void TaskPlacement::setLayout(TaskLayout *layout)
{
    if (m_layout == layout) {
        return;
    }
    if (m_layout) {
        disconnect(m_layout, nullptr, this, nullptr);
    }
    m_layout = layout;
    if (m_layout) {
        connect(m_layout, &TaskLayout::layoutChanged, this, &TaskPlacement::placementChanged);
    }
    Q_EMIT layoutChanged();
}

int TaskPlacement::index() const
{
    return m_index;
}

void TaskPlacement::setIndex(int index)
{
    if (m_index != index) {
        m_index = index;
        Q_EMIT indexChanged();
    }
}

int TaskPlacement::column() const
{
    return m_layout ? m_layout->columnOf(m_index) : 0;
}

int TaskPlacement::row() const
{
    return m_layout ? m_layout->rowOf(m_index) : 0;
}

qreal TaskPlacement::x() const
{
    return m_layout ? m_layout->taskX(m_index) : 0;
}

qreal TaskPlacement::rowOffset() const
{
    return m_layout ? m_layout->rowOffset(m_index) : 0;
}

qreal TaskPlacement::scrollPosition() const
{
    return m_layout ? m_layout->scrollPositionForTask(m_index) : 0;
}
