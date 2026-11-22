// SPDX-FileCopyrightText: 2024 Micah Stanley <stanleymicah@proton.me>
// SPDX-FileCopyrightText: 2024-2025 Luis Büchi <luis.buechi@kdemail.net>
// SPDX-FileCopyrightText: 2026 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include <QObject>
#include <QPointer>
#include <QSizeF>
#include <qqmlintegration.h>

/**
 * Where the tasks are placed in the task switcher when it is opened, and how the list scrolls.
 *
 * Tasks are placed in columns from right to left, filling each column from top to bottom.
 * Positions are in the coordinates of the task list, relative to the task centered on the screen.
 */
class TaskLayout : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_UNCREATABLE("Abstract base class, use CarouselTaskLayout or GridTaskLayout")

    // ~~ inputs ~~
    Q_PROPERTY(int count READ count WRITE setCount NOTIFY layoutChanged)
    // size of a real window, the previews are scaled down from it
    Q_PROPERTY(QSizeF windowSize READ windowSize WRITE setWindowSize NOTIFY layoutChanged)
    // spacing between tasks
    Q_PROPERTY(qreal spacing READ spacing WRITE setSpacing NOTIFY layoutChanged)
    // height of the header above each preview
    Q_PROPERTY(qreal headerHeight READ headerHeight WRITE setHeaderHeight NOTIFY layoutChanged)
    Q_PROPERTY(qreal scrollPosition READ scrollPosition WRITE setScrollPosition NOTIFY scrollPositionChanged)

    // ~~ layout ~~
    Q_PROPERTY(int rows READ rows NOTIFY layoutChanged)
    Q_PROPERTY(int columnCount READ columnCount NOTIFY layoutChanged)
    // scale of the previews compared to the window
    Q_PROPERTY(qreal previewScale READ previewScale NOTIFY layoutChanged)
    // size of a task, the preview with its header
    Q_PROPERTY(qreal taskWidth READ taskWidth NOTIFY layoutChanged)
    Q_PROPERTY(qreal taskHeight READ taskHeight NOTIFY layoutChanged)
    // width of all the columns
    Q_PROPERTY(qreal contentWidth READ contentWidth NOTIFY layoutChanged)
    // how far the bottom row extends below a vertically centered task
    Q_PROPERTY(qreal rowsOverhang READ rowsOverhang NOTIFY layoutChanged)
    // how much the task list shrinks when dragged further up than its opened position
    Q_PROPERTY(qreal overDragScaleRange READ overDragScaleRange NOTIFY layoutChanged)
    // Whether the task list zooms into a task to launch it.
    Q_PROPERTY(bool zoomsIntoTask READ zoomsIntoTask CONSTANT)

    // ~~ scrolling ~~
    // the range the scroll position rests in
    Q_PROPERTY(qreal scrollMinimum READ scrollMinimum NOTIFY layoutChanged)
    Q_PROPERTY(qreal scrollMaximum READ scrollMaximum NOTIFY layoutChanged)
    // the scroll position that is shown, which may resist going past the ends
    Q_PROPERTY(qreal displayedScrollPosition READ displayedScrollPosition NOTIFY displayedScrollPositionChanged)

public:
    explicit TaskLayout(QObject *parent = nullptr);

    int count() const;
    void setCount(int count);
    QSizeF windowSize() const;
    void setWindowSize(const QSizeF &windowSize);
    qreal spacing() const;
    void setSpacing(qreal spacing);
    qreal headerHeight() const;
    void setHeaderHeight(qreal headerHeight);
    qreal scrollPosition() const;
    void setScrollPosition(qreal scrollPosition);

    virtual int rows() const = 0;
    virtual qreal previewScale() const = 0;
    virtual qreal overDragScaleRange() const = 0;
    virtual qreal scrollMinimum() const = 0;
    virtual qreal scrollMaximum() const = 0;
    virtual bool zoomsIntoTask() const = 0;

    int columnCount() const;
    qreal taskWidth() const;
    qreal taskHeight() const;
    qreal contentWidth() const;
    qreal rowsOverhang() const;
    qreal displayedScrollPosition() const;

    Q_INVOKABLE int columnOf(int index) const;
    Q_INVOKABLE int rowOf(int index) const;
    // x position of the task in the list
    Q_INVOKABLE qreal taskX(int index) const;
    // vertical offset of the task's row from a vertically centered task
    Q_INVOKABLE qreal rowOffset(int index) const;

    // the scroll position to show the task
    Q_INVOKABLE virtual qreal scrollPositionForTask(int index) const = 0;
    // the task shown at the scroll position, in the same row as currentIndex
    Q_INVOKABLE int taskAt(qreal scrollPosition, int currentIndex) const;
    Q_INVOKABLE qreal clampScroll(qreal scrollPosition) const;
    // where the list rests from the scroll position, with currentIndex as the current task
    Q_INVOKABLE virtual qreal restingScrollPosition(qreal scrollPosition, int currentIndex) const = 0;

Q_SIGNALS:
    void layoutChanged();
    void scrollPositionChanged();
    void displayedScrollPositionChanged();

protected:
    // distance between columns
    qreal step() const;
    // the column shown at the scroll position, can be out of range
    virtual qreal columnAt(qreal scrollPosition) const = 0;

private:
    int m_count = 0;
    QSizeF m_windowSize;
    qreal m_spacing = 0;
    qreal m_headerHeight = 0;
    qreal m_scrollPosition = 0;
};

/**
 * A single row of large tasks, the current task centered on the screen.
 */
class CarouselTaskLayout : public TaskLayout
{
    Q_OBJECT
    QML_ELEMENT

public:
    using TaskLayout::TaskLayout;

    int rows() const override;
    qreal previewScale() const override;
    qreal overDragScaleRange() const override;
    qreal scrollMinimum() const override;
    qreal scrollMaximum() const override;
    bool zoomsIntoTask() const override;
    qreal scrollPositionForTask(int index) const override;
    // always on the current task
    qreal restingScrollPosition(qreal scrollPosition, int currentIndex) const override;

protected:
    qreal columnAt(qreal scrollPosition) const override;
};

/**
 * Multiple rows of smaller tasks for large screens.
 */
class GridTaskLayout : public TaskLayout
{
    Q_OBJECT
    QML_ELEMENT

public:
    using TaskLayout::TaskLayout;

    int rows() const override;
    qreal previewScale() const override;
    qreal overDragScaleRange() const override;
    qreal scrollMinimum() const override;
    qreal scrollMaximum() const override;
    bool zoomsIntoTask() const override;
    // the scroll position where the task's column is on the right edge, as far as the grid can scroll
    qreal scrollPositionForTask(int index) const override;
    // anywhere within the range
    qreal restingScrollPosition(qreal scrollPosition, int currentIndex) const override;

protected:
    // the column on the right edge
    qreal columnAt(qreal scrollPosition) const override;

private:
    bool contentFits() const;
};

/**
 * The place of one task in a layout, as properties that update when the layout changes.
 */
class TaskPlacement : public QObject
{
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(TaskLayout *layout READ layout WRITE setLayout NOTIFY layoutChanged)
    Q_PROPERTY(int index READ index WRITE setIndex NOTIFY indexChanged)

    Q_PROPERTY(int column READ column NOTIFY placementChanged)
    Q_PROPERTY(int row READ row NOTIFY placementChanged)

    Q_PROPERTY(qreal x READ x NOTIFY placementChanged)
    Q_PROPERTY(qreal rowOffset READ rowOffset NOTIFY placementChanged)
    Q_PROPERTY(qreal scrollPosition READ scrollPosition NOTIFY placementChanged)

public:
    explicit TaskPlacement(QObject *parent = nullptr);

    TaskLayout *layout() const;
    void setLayout(TaskLayout *layout);
    int index() const;
    void setIndex(int index);

    int column() const;
    int row() const;
    qreal x() const;
    qreal rowOffset() const;
    qreal scrollPosition() const;

Q_SIGNALS:
    void layoutChanged();
    void indexChanged();
    void placementChanged();

private:
    QPointer<TaskLayout> m_layout;
    int m_index = 0;
};
