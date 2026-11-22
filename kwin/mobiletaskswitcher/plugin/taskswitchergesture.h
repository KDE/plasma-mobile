// SPDX-FileCopyrightText: 2024 Micah Stanley <stanleymicah@proton.me>
// SPDX-FileCopyrightText: 2024-2025 Luis Büchi <luis.buechi@kdemail.net>
// SPDX-FileCopyrightText: 2026 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include <QElapsedTimer>
#include <QObject>
#include <qqmlintegration.h>

/**
 * Interprets a swipe from the bottom screen edge for the task switcher.
 *
 * It keeps track of what the gesture currently means (the intent), and requests
 * how the task switcher should react while it is in progress. When the gesture
 * ends, endAction() tells what should happen.
 */
class TaskSwitcherGesture : public QObject
{
    Q_OBJECT
    QML_ELEMENT

    // What the gesture would do if it ended now
    Q_PROPERTY(Intent intent READ intent WRITE setIntent NOTIFY intentChanged)
    // Scrub mode: a mostly horizontal drag along the screen edge to scrub through tasks
    Q_PROPERTY(bool scrubbing READ scrubbing NOTIFY scrubbingChanged)

    // The touch position relative to where the gesture started, see moveTouch()
    Q_PROPERTY(qreal touchX READ touchX NOTIFY touchChanged)
    Q_PROPERTY(qreal touchY READ touchY NOTIFY touchChanged)
    // Velocity of the touch (px/ms), filtered to smooth it out
    Q_PROPERTY(qreal xVelocity READ xVelocity NOTIFY touchChanged)
    Q_PROPERTY(qreal yVelocity READ yVelocity NOTIFY touchChanged)

    // Context set from the task switcher

    // Whether the switcher was invoked from an app (as opposed to the home screen)
    Q_PROPERTY(bool startedInApp MEMBER m_startedInApp NOTIFY contextChanged)
    // Whether the task drawer is opened
    Q_PROPERTY(bool taskDrawerOpened MEMBER m_taskDrawerOpened NOTIFY contextChanged)
    Q_PROPERTY(int tasksCount MEMBER m_tasksCount NOTIFY contextChanged)

    // Thresholds

    // Below this distance, ending the gesture undoes it
    Q_PROPERTY(qreal undoThreshold MEMBER m_undoThreshold NOTIFY contextChanged)
    // The distance at which the task drawer is fully opened
    Q_PROPERTY(qreal openedDistance MEMBER m_openedDistance NOTIFY contextChanged)
    // Above this distance the gesture goes home (from an app or the switcher)
    Q_PROPERTY(qreal homeThreshold MEMBER m_homeThreshold NOTIFY contextChanged)
    // How far below homeThreshold the gesture must come back to leave it again, to prevent flickering
    Q_PROPERTY(qreal homeThresholdHysteresis MEMBER m_homeThresholdHysteresis NOTIFY contextChanged)
    // Horizontal distance needed to start scrub mode
    Q_PROPERTY(qreal scrubDistance MEMBER m_scrubDistance NOTIFY contextChanged)
    // Scrub mode only starts this close to the screen edge
    Q_PROPERTY(qreal scrubMaxEdgeDistance MEMBER m_scrubMaxEdgeDistance NOTIFY contextChanged)

public:
    enum class Intent {
        Undecided, // Undo the gesture
        HorizontalSwipe, // Quick switch to an adjacent task
        TaskSwitcher, // Open the task drawer
        Home, // Go to the home screen
    };
    Q_ENUM(Intent)

    // Where the task drawer should move to, the actual offsets are defined by the view
    enum class DrawerPosition {
        Opened, // Tasks shown in the drawer
        Peek, // Drawer peeking in, when invoked from the home screen
        OffscreenHome, // Drawer out of view, when invoked from the home screen
        OffscreenTask, // Drawer out of view, when invoked from an app
    };
    Q_ENUM(DrawerPosition)

    enum class EndAction {
        Close, // Close the switcher, going to the home screen
        ReturnToApp, // Go back to the app the gesture started in
        ReturnToSwitcher, // Stay in the opened task drawer
        OpenSwitcher, // Open the task drawer
        QuickSwitch, // Switch to an adjacent task
        OpenSwitcherFromScrub, // Leave scrub mode into the opened task drawer
        LaunchScrubbedTask, // Open the task selected in scrub mode
    };
    Q_ENUM(EndAction)

    explicit TaskSwitcherGesture(QObject *parent = nullptr);

    Intent intent() const;
    void setIntent(Intent intent);
    bool scrubbing() const;
    qreal touchX() const;
    qreal touchY() const;
    qreal xVelocity() const;
    qreal yVelocity() const;

    // Reset all gesture state, called when the task switcher is (re)started
    Q_INVOKABLE void reset();

    // A new touch starts: forget the position and velocity of the last one
    Q_INVOKABLE void resetTouch();
    // The touch moved, relative to where it started: x along the screen edge, y away from it
    Q_INVOKABLE void moveTouch(qreal x, qreal y);

    // Whether this movement should be handled as scrub mode. Once scrubbing, it stays that way.
    Q_INVOKABLE bool shouldScrub() const;
    // Enter scrub mode, requests haptic feedback the first time
    Q_INVOKABLE void enterScrub();
    Q_INVOKABLE void leaveScrub();

    // Update the intent from the touch, emitting the requests for how the switcher should react
    Q_INVOKABLE void update();

    // What to do now that the gesture has ended
    Q_INVOKABLE TaskSwitcherGesture::EndAction endAction() const;

Q_SIGNALS:
    void intentChanged();
    void scrubbingChanged();
    void touchChanged();
    void contextChanged();

    void backgroundOpacityRequested(qreal opacity);
    void vibrationRequested();
    void drawerPositionRequested(TaskSwitcherGesture::DrawerPosition position, bool immediate);

private:
    // Change the intent from a gesture, with haptic feedback when it first decides to open the task drawer
    void changeIntent(Intent intent);

    // Whether the switcher was invoked from an app, or the drawer is opened
    bool notHomeScreen() const;
    void updateVelocity(qreal x, qreal y);

    Intent m_intent = Intent::Undecided;
    bool m_scrubbing = false;
    bool m_reachedHomeThreshold = false;

    // haptic feedback is only given once per gesture
    bool m_hasVibrated = false;

    qreal m_touchX = 0;
    qreal m_touchY = 0;
    qreal m_xVelocity = 0;
    qreal m_yVelocity = 0;
    // the first touch event has no velocity yet, it is measured from the second one
    bool m_velocityKnown = false;
    // the touch position the velocity was last measured at, and the time since
    qreal m_sampleX = 0;
    qreal m_sampleY = 0;
    QElapsedTimer m_touchTimer;

    bool m_startedInApp = false;
    bool m_taskDrawerOpened = false;
    int m_tasksCount = 0;

    qreal m_undoThreshold = 0;
    qreal m_openedDistance = 0;
    qreal m_homeThreshold = 0;
    qreal m_homeThresholdHysteresis = 0;
    qreal m_scrubDistance = 0;
    qreal m_scrubMaxEdgeDistance = 0;
};
