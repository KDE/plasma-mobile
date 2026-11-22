// SPDX-FileCopyrightText: 2024 Micah Stanley <stanleymicah@proton.me>
// SPDX-FileCopyrightText: 2024-2025 Luis Büchi <luis.buechi@kdemail.net>
// SPDX-FileCopyrightText: 2026 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "taskswitchergesture.h"

#include <algorithm>
#include <cmath>

// Squared velocity (px/ms) above which the movement is treated as a flick
static constexpr qreal FLICK_VELOCITY_THRESHOLD = 0.5 * 0.5;

// Time constant of the velocity filter (s)
static constexpr qreal VELOCITY_FILTER_TIME_CONSTANT = 0.03;

// Ratio between the y and x velocity that separates vertical and horizontal flicks.
// With 1.7, swipes up to ~60 degrees from horizontal are counted as horizontal.
static constexpr qreal FLICK_DIRECTION_RATIO = 1.7;

// Scrub mode requires the movement to be almost completely horizontal...
static constexpr qreal SCRUB_DIRECTION_RATIO = 3;

// ...and not a fast flick (px/ms)
// TODO evaluate whether to keep this, it's kinda awkward
static constexpr qreal SCRUB_MAX_VELOCITY = 2.5;

TaskSwitcherGesture::TaskSwitcherGesture(QObject *parent)
    : QObject{parent}
{
}

TaskSwitcherGesture::Intent TaskSwitcherGesture::intent() const
{
    return m_intent;
}

void TaskSwitcherGesture::setIntent(Intent intent)
{
    if (m_intent != intent) {
        m_intent = intent;
        Q_EMIT intentChanged();
    }
}

bool TaskSwitcherGesture::scrubbing() const
{
    return m_scrubbing;
}

void TaskSwitcherGesture::reset()
{
    setIntent(Intent::Undecided);
    leaveScrub();
    m_reachedHomeThreshold = false;
    m_hasVibrated = false;
}

qreal TaskSwitcherGesture::touchX() const
{
    return m_touchX;
}

qreal TaskSwitcherGesture::touchY() const
{
    return m_touchY;
}

qreal TaskSwitcherGesture::xVelocity() const
{
    return m_xVelocity;
}

qreal TaskSwitcherGesture::yVelocity() const
{
    return m_yVelocity;
}

void TaskSwitcherGesture::resetTouch()
{
    m_touchTimer.invalidate();
    m_touchX = 0;
    m_touchY = 0;
    m_xVelocity = 0;
    m_yVelocity = 0;
    m_velocityKnown = false;
    Q_EMIT touchChanged();
}

void TaskSwitcherGesture::moveTouch(qreal x, qreal y)
{
    updateVelocity(x, y);
    m_touchX = x;
    m_touchY = y;
    Q_EMIT touchChanged();
}

void TaskSwitcherGesture::updateVelocity(qreal x, qreal y)
{
    if (!m_touchTimer.isValid()) {
        m_sampleX = x;
        m_sampleY = y;
        m_touchTimer.start();
        return;
    }
    const qint64 frameTime = m_touchTimer.restart();
    if (frameTime == 0) {
        // Skip because otherwise we get NaN later on. Not sure why this triggers as often as it does
        return;
    }

    // Implements an exponentially weighted moving average (EWMA) filter (= exponential smoothing)
    // Smoothing factor is approximated each event to achieve a chosen filter time constant
    const qreal smoothingFactor = std::min(frameTime / (1000 * VELOCITY_FILTER_TIME_CONSTANT), 0.8);
    m_xVelocity += smoothingFactor * ((x - m_sampleX) / frameTime - m_xVelocity);
    m_yVelocity += smoothingFactor * ((y - m_sampleY) / frameTime - m_yVelocity);
    m_sampleX = x;
    m_sampleY = y;
    m_velocityKnown = true;
}

bool TaskSwitcherGesture::notHomeScreen() const
{
    return m_startedInApp || m_taskDrawerOpened;
}

void TaskSwitcherGesture::changeIntent(Intent intent)
{
    if (m_intent != Intent::TaskSwitcher && intent == Intent::TaskSwitcher && !m_hasVibrated) {
        m_hasVibrated = true;
        Q_EMIT vibrationRequested();
    }
    setIntent(intent);
}

bool TaskSwitcherGesture::shouldScrub() const
{
    if (m_scrubbing) {
        // once in scrub mode, don't allow leaving it, that can result in inconsistent UX
        return true;
    }
    return std::abs(m_xVelocity) > std::abs(m_yVelocity) * SCRUB_DIRECTION_RATIO //
        && std::abs(m_xVelocity) < SCRUB_MAX_VELOCITY //
        && std::abs(m_touchX) > m_scrubDistance * 0.95 // moved far enough sideways
        && std::abs(m_touchY) < m_scrubMaxEdgeDistance // close to the screen edge
        && m_tasksCount > 0 //
        && !m_taskDrawerOpened;
}

void TaskSwitcherGesture::enterScrub()
{
    if (m_scrubbing) {
        return;
    }
    if (!m_hasVibrated) {
        m_hasVibrated = true;
        Q_EMIT vibrationRequested();
    }
    m_scrubbing = true;
    Q_EMIT scrubbingChanged();
}

void TaskSwitcherGesture::leaveScrub()
{
    if (m_scrubbing) {
        m_scrubbing = false;
        Q_EMIT scrubbingChanged();
    }
}

void TaskSwitcherGesture::update()
{
    const qreal distance = std::abs(m_touchY);
    const bool notHome = notHomeScreen();
    const qreal xVelocity = m_xVelocity;
    const qreal yVelocity = m_yVelocity;
    const qreal squaredVelocity = xVelocity * xVelocity + yVelocity * yVelocity;

    if (distance > m_homeThreshold) {
        m_reachedHomeThreshold = true;
        Q_EMIT backgroundOpacityRequested(notHome ? 0 : 1);
    } else if (distance > m_undoThreshold) {
        Q_EMIT backgroundOpacityRequested(1);
    } else {
        Q_EMIT backgroundOpacityRequested(notHome ? 1 : 0);
    }

    if (squaredVelocity > FLICK_VELOCITY_THRESHOLD) {
        if (yVelocity > std::abs(xVelocity) * FLICK_DIRECTION_RATIO) {
            // downwards flick
            changeIntent(Intent::Undecided);
            if (distance < m_undoThreshold) {
                Q_EMIT drawerPositionRequested(notHome ? DrawerPosition::Opened : DrawerPosition::OffscreenHome, false);
            }
        } else if (-yVelocity > std::abs(xVelocity) * FLICK_DIRECTION_RATIO || (m_reachedHomeThreshold && notHome)) {
            // upwards flick, or above the home threshold
            if (notHome) {
                // in an app or the task switcher: go home
                changeIntent(Intent::Home);
                if (m_reachedHomeThreshold) {
                    Q_EMIT drawerPositionRequested(DrawerPosition::OffscreenTask, false);
                }
            } else if (distance > m_undoThreshold) {
                // from the home screen: keep the task switcher in view
                changeIntent(Intent::TaskSwitcher);
                Q_EMIT drawerPositionRequested(DrawerPosition::Peek, false);
            }
        } else if (!m_reachedHomeThreshold && !m_scrubbing) {
            // sideways flick
            if (notHome) {
                Q_EMIT drawerPositionRequested(DrawerPosition::Opened, distance < m_openedDistance);
            }
            changeIntent(Intent::HorizontalSwipe);
        }
        return;
    }

    if (distance > m_undoThreshold) {
        // just moved out of the undo threshold
        if (m_intent < Intent::TaskSwitcher) {
            changeIntent(Intent::Home);
        }

        if (distance > m_homeThreshold) {
            // no haptic feedback anymore once the home threshold was passed
            m_hasVibrated = true;
            if (notHome) {
                // move the task switcher out of view, going home
                changeIntent(Intent::Home);
                Q_EMIT drawerPositionRequested(DrawerPosition::OffscreenTask, false);
            } else {
                // from the home screen: keep the task switcher in view
                changeIntent(Intent::TaskSwitcher);
                Q_EMIT drawerPositionRequested(DrawerPosition::Peek, false);
            }
        } else if (distance < m_homeThreshold - m_homeThresholdHysteresis || !m_reachedHomeThreshold) {
            // only leave the home threshold some distance below it, to prevent flickering
            m_reachedHomeThreshold = false;
            // (before the velocity is known, it is 0, which doesn't mean the movement is slow)
            if (squaredVelocity < FLICK_VELOCITY_THRESHOLD && m_velocityKnown) {
                // slow enough, move the task switcher into view
                changeIntent(Intent::TaskSwitcher);
                Q_EMIT drawerPositionRequested(notHome ? DrawerPosition::Opened : DrawerPosition::Peek, false);
            }
        }
    } else {
        // below the undo threshold: go back to the task drawer if it is open, otherwise undo
        m_reachedHomeThreshold = false;
        if (m_taskDrawerOpened) {
            changeIntent(Intent::TaskSwitcher);
            Q_EMIT drawerPositionRequested(DrawerPosition::Opened, false);
        } else {
            changeIntent(Intent::Undecided);
            Q_EMIT drawerPositionRequested(notHome ? DrawerPosition::Opened : DrawerPosition::OffscreenHome, false);
        }
    }
}

TaskSwitcherGesture::EndAction TaskSwitcherGesture::endAction() const
{
    if (m_tasksCount == 0) {
        return EndAction::Close;
    }

    if (m_scrubbing) {
        // TODO do we want to handle upwards flick to dismiss in scrub mode?
        if (m_taskDrawerOpened || std::abs(m_touchY) > m_undoThreshold) {
            return EndAction::OpenSwitcherFromScrub;
        }
        return EndAction::LaunchScrubbedTask;
    }

    switch (m_intent) {
    case Intent::Undecided:
        if (m_taskDrawerOpened) {
            return EndAction::ReturnToSwitcher;
        }
        return m_startedInApp ? EndAction::ReturnToApp : EndAction::Close;
    case Intent::HorizontalSwipe:
        return EndAction::QuickSwitch;
    case Intent::TaskSwitcher:
        return EndAction::OpenSwitcher;
    case Intent::Home:
        return EndAction::Close;
    }
    return EndAction::Close;
}
