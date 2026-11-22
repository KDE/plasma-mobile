// SPDX-FileCopyrightText: 2024 Micah Stanley <stanleymicah@proton.me>
// SPDX-FileCopyrightText: 2024-2025 Luis Büchi <luis.buechi@kdemail.net>
// SPDX-FileCopyrightText: 2026 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include <QObject>
#include <QPointer>
#include <qqmlintegration.h>

#include "tasklayout.h"

/**
 * Where the task switcher visually is:
 * Its scroll and open position, the scale the task list is shown at, and which task is current.
 */
class TaskNavigator : public QObject
{
    Q_OBJECT
    QML_ELEMENT

    // Inputs

    Q_PROPERTY(TaskLayout *layout READ layout WRITE setLayout NOTIFY layoutChanged)
    // Whether the current task follows the scroll position, see updateCurrentTask()
    Q_PROPERTY(bool tracking READ tracking WRITE setTracking NOTIFY trackingChanged)
    // Whether the task drawer finished opening
    Q_PROPERTY(bool taskDrawerOpened READ taskDrawerOpened WRITE setTaskDrawerOpened NOTIFY originChanged)
    // The y position at which the task switcher is opened
    Q_PROPERTY(qreal openedYPosition READ openedYPosition WRITE setOpenedYPosition NOTIFY scaleChanged)
    // While closing, the scale the task list shrinks with (animated down from the scale it had), otherwise 1
    Q_PROPERTY(qreal closingScale READ closingScale WRITE setClosingScale NOTIFY scaleChanged)

    // State

    // Whether the task switcher was invoked from an app, rather than the home screen
    Q_PROPERTY(bool startedInApp READ startedInApp WRITE setStartedInApp NOTIFY originChanged)
    // Whether the task switcher comes from the home screen, and the task drawer isn't opened yet
    Q_PROPERTY(bool onHomeScreen READ onHomeScreen NOTIFY originChanged)
    // The scroll position of the task list
    Q_PROPERTY(qreal xPosition READ xPosition WRITE setXPosition NOTIFY xPositionChanged)
    // How far the task switcher is opened: 0 is the current task filling the screen,
    // the opened position is set by the view, and it can be dragged further up
    Q_PROPERTY(qreal yPosition READ yPosition WRITE setYPosition NOTIFY yPositionChanged)
    // The task the task switcher is at
    Q_PROPERTY(int currentTaskIndex READ currentTaskIndex WRITE setCurrentTaskIndex NOTIFY currentTaskIndexChanged)
    // The task the task switcher was invoked from
    Q_PROPERTY(int initialTaskIndex READ initialTaskIndex NOTIFY initialTaskIndexChanged)
    // The task shown as current: only updated when a gesture starts, so that the tasks don't
    // change their animations while the gesture plays out
    Q_PROPERTY(int displayedTaskIndex READ displayedTaskIndex NOTIFY displayedTaskIndexChanged)

    // Scale

    // The scale of the task list: the task fills the screen at y=0, it shrinks to the layout's size
    // until the opened position, and a bit further (with resistance) when dragged further up
    Q_PROPERTY(qreal scale READ scale NOTIFY scaleChanged)
    // Whether the task list is dragged further up than the opened position
    Q_PROPERTY(bool overDragged READ overDragged NOTIFY scaleChanged)
    // How far the task list follows the finger further up than the opened position, with resistance
    Q_PROPERTY(qreal overDragOffset READ overDragOffset NOTIFY scaleChanged)
    // How far the task list is opened, from 0 (the current task fills the screen) to 1 (opened)
    Q_PROPERTY(qreal openProgress READ openProgress NOTIFY scaleChanged)

public:
    explicit TaskNavigator(QObject *parent = nullptr);

    TaskLayout *layout() const;
    void setLayout(TaskLayout *layout);
    bool tracking() const;
    void setTracking(bool tracking);
    bool taskDrawerOpened() const;
    void setTaskDrawerOpened(bool taskDrawerOpened);
    qreal openedYPosition() const;
    void setOpenedYPosition(qreal openedYPosition);
    qreal closingScale() const;
    void setClosingScale(qreal closingScale);

    bool startedInApp() const;
    void setStartedInApp(bool startedInApp);
    bool onHomeScreen() const;
    qreal xPosition() const;
    void setXPosition(qreal xPosition);
    qreal yPosition() const;
    void setYPosition(qreal yPosition);
    int currentTaskIndex() const;
    void setCurrentTaskIndex(int index);
    int initialTaskIndex() const;
    int displayedTaskIndex() const;

    qreal scale() const;
    bool overDragged() const;
    qreal overDragOffset() const;
    qreal openProgress() const;

    // start at the task, as the one the task switcher was invoked from
    Q_INVOKABLE void start(int index);
    Q_INVOKABLE void beginGesture();
    Q_INVOKABLE void goToTask(int index);
    // Follow the gesture's touch position, relative to where it started
    Q_INVOKABLE void followTouch(qreal touchX, qreal touchY);
    // Make the task at the scroll position current, if tracking
    Q_INVOKABLE void updateCurrentTask();
    // Keep the same position relative to the current task in the new layout
    Q_INVOKABLE void keepPosition(TaskLayout *from, TaskLayout *to);
    // Move to where the layout rests, e.g. after tasks were removed
    Q_INVOKABLE void restInLayout();
    Q_INVOKABLE void removeTasks(int first, int last, int count);

    // The task to go to after a gesture moved the list sideways: only the tasks on the left (older) are switched to
    Q_INVOKABLE int nearestTask() const;
    // The task to snap to after dragging the list, in the direction it was moving
    Q_INVOKABLE int snapTarget(bool movingRight) const;
    // The task scrubbed to, touchX away from where scrubbing started
    Q_INVOKABLE int scrubTarget(qreal touchX, qreal scrubDistance) const;
    // The task to quick switch to, flicking in the direction (-1 or 1). -1 if there is none
    Q_INVOKABLE int quickSwitchTarget(int direction) const;

Q_SIGNALS:
    void layoutChanged();
    void trackingChanged();
    void originChanged();
    void xPositionChanged();
    void yPositionChanged();
    void currentTaskIndexChanged();
    void initialTaskIndexChanged();
    void displayedTaskIndexChanged();
    void scaleChanged();

private:
    int count() const;
    qreal scrollPositionForTask(int index) const;
    int clampIndex(int index) const;
    void setInitialTaskIndex(int index);
    void setDisplayedTaskIndex(int index);

    QPointer<TaskLayout> m_layout;
    bool m_tracking = true;
    bool m_taskDrawerOpened = false;
    qreal m_openedYPosition = 0;
    qreal m_closingScale = 1;
    bool m_startedInApp = false;
    qreal m_xPosition = 0;
    qreal m_yPosition = 0;
    int m_currentTaskIndex = 0;
    int m_initialTaskIndex = 0;
    int m_displayedTaskIndex = 0;
};
