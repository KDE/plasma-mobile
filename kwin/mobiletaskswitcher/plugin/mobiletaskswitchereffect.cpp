// SPDX-FileCopyrightText: 2021 Vlad Zahorodnii <vlad.zahorodnii@kde.org>
// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-FileCopyrightText: 2024 Luis Büchi <luis.buechi@kdemail.net>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "mobiletaskswitchereffect.h"

#include <QDBusConnection>
#include <QDBusMessage>
#include <QDBusReply>
#include <QKeyEvent>
#include <QMetaObject>
#include <QQuickItem>
#include <window.h>

using namespace std::chrono_literals;

namespace KWin
{

MobileTaskSwitcherState::MobileTaskSwitcherState(QObject *parent)
    : QObject{parent}
    , m_doubleClickTimer{new QElapsedTimer{}}
    , m_shutdownTimer{new QTimer{this}}
{
    // Configure close timer
    m_shutdownTimer->setSingleShot(true);
    m_shutdownTimer->setInterval(300ms);
    connect(m_shutdownTimer, &QTimer::timeout, this, &MobileTaskSwitcherState::realDeactivate);
}

void MobileTaskSwitcherState::init(KWin::QuickSceneEffect *parent)
{
    m_effectState = new EffectTouchBorderState(parent);
    m_border = new EffectTouchBorder{m_effectState};
    m_taskModel = new TaskModel{parent};
    m_effect = parent;

    // Connect signals
    connect(this, &MobileTaskSwitcherState::gestureEnabledChanged, this, &MobileTaskSwitcherState::refreshBorders);
    connect(m_border, &EffectTouchBorder::touchPositionChanged, this, &MobileTaskSwitcherState::processTouchPositionChanged);
    connect(this, &MobileTaskSwitcherState::gestureInProgressChanged, this, [this]() {
        if (gestureInProgress()) {
            invokeEffect();
        }
    });
    connect(m_effectState, &EffectTouchBorderState::inProgressChanged, this, &MobileTaskSwitcherState::gestureInProgressChanged);
    connect(effects, &EffectsHandler::screenAboutToLock, this, &MobileTaskSwitcherState::realDeactivate);

    refreshBorders();
}

bool MobileTaskSwitcherState::gestureEnabled() const
{
    return m_gestureEnabled;
}

void MobileTaskSwitcherState::setGestureEnabled(bool gestureEnabled)
{
    m_gestureEnabled = gestureEnabled;
    Q_EMIT gestureEnabledChanged();
}

void MobileTaskSwitcherState::refreshBorders()
{
    if (m_gestureEnabled) {
        m_border->setBorders({ElectricBorder::ElectricBottom});
    } else {
        m_border->setBorders({});
    }
}

bool MobileTaskSwitcherState::gestureInProgress() const
{
    return m_effectState->inProgress();
}

void MobileTaskSwitcherState::setGestureInProgress(bool gestureInProgress)
{
    if (m_status == Status::Stopped) {
        return;
    }
    m_effectState->setInProgress(gestureInProgress);
}

bool MobileTaskSwitcherState::wasInActiveTask() const
{
    return m_wasInActiveTask;
}

void MobileTaskSwitcherState::setWasInActiveTask(bool wasInActiveTask)
{
    if (m_wasInActiveTask != wasInActiveTask) {
        m_wasInActiveTask = wasInActiveTask;
        Q_EMIT wasInActiveTaskChanged();
    }
}

void MobileTaskSwitcherState::updateWasInActiveTask(KWin::Window *window)
{
    bool newWasInActiveTask = false;
    if (window) {
        newWasInActiveTask = !window->isDesktop();
    }
    setWasInActiveTask(newWasInActiveTask);
}

qreal MobileTaskSwitcherState::touchXPosition() const
{
    return m_touchXPosition;
}

qreal MobileTaskSwitcherState::touchYPosition() const
{
    return m_touchYPosition;
}

qreal MobileTaskSwitcherState::xVelocity() const
{
    return m_xVelocity;
}

qreal MobileTaskSwitcherState::yVelocity() const
{
    return m_yVelocity;
}

qreal MobileTaskSwitcherState::totalSquaredVelocity() const
{
    return m_totalSquaredVelocity;
}

qreal MobileTaskSwitcherState::flickVelocityThreshold() const
{
    return m_flickVelocityThreshold;
}

void MobileTaskSwitcherState::setFlickVelocityThreshold(qreal flickVelocityThreshold)
{
    if (m_flickVelocityThreshold != flickVelocityThreshold) {
        m_flickVelocityThreshold = flickVelocityThreshold;
        Q_EMIT flickVelocityThresholdChanged();
    }
}

qreal MobileTaskSwitcherState::xPosition() const
{
    return m_xPosition;
}

void MobileTaskSwitcherState::setXPosition(qreal xPosition)
{
    if (m_xPosition != xPosition) {
        m_xPosition = xPosition;
        Q_EMIT xPositionChanged();
    }
}

qreal MobileTaskSwitcherState::yPosition() const
{
    return m_yPosition;
}

void MobileTaskSwitcherState::setYPosition(qreal yPosition)
{
    if (m_yPosition != yPosition) {
        m_yPosition = yPosition;
        Q_EMIT yPositionChanged();
    }
}

MobileTaskSwitcherState::Status MobileTaskSwitcherState::status() const
{
    return m_status;
}

void MobileTaskSwitcherState::setStatus(Status status)
{
    if (m_status != status) {
        if (status == Status::Inactive) {
            setYPosition(0);
        }
        m_status = status;
        Q_EMIT statusChanged();
    }
}

int MobileTaskSwitcherState::currentTaskIndex() const
{
    return m_currentTaskIndex;
}

void MobileTaskSwitcherState::setCurrentTaskIndex(int newTaskIndex)
{
    if (m_currentTaskIndex != newTaskIndex) {
        m_currentTaskIndex = newTaskIndex;
        Q_EMIT currentTaskIndexChanged();
    }
}

int MobileTaskSwitcherState::initialTaskIndex() const
{
    return m_initialTaskIndex;
}

void MobileTaskSwitcherState::setInitialTaskIndex(int newTaskIndex)
{
    if (m_initialTaskIndex != newTaskIndex) {
        m_initialTaskIndex = newTaskIndex;
        Q_EMIT initialTaskIndexChanged();
    }
}

TaskModel *MobileTaskSwitcherState::taskModel() const
{
    return m_taskModel;
}

void MobileTaskSwitcherState::restartDoubleClickTimer()
{
    m_doubleClickTimer->restart();
}

void MobileTaskSwitcherState::calculateFilteredVelocity(qreal primaryDelta, qreal orthogonalDelta)
{
    static qreal prevPrimaryDelta = 0;
    static qreal prevOrthogonalDelta = 0;

    qint64 frameTime = 0;
    if (!m_frameTimer.isValid()) {
        prevPrimaryDelta = 0;
        prevOrthogonalDelta = 0;
        m_frameTimer.start();
        return;
    }
    frameTime = m_frameTimer.restart();
    if (frameTime == 0) {
        // Skip because otherwise we get NaN later on. Not sure why this triggers as often as it does
        return;
    }

    qreal framePrimaryDelta = primaryDelta - prevPrimaryDelta;
    qreal frameOrthogonalDelta = orthogonalDelta - prevOrthogonalDelta;
    prevPrimaryDelta = primaryDelta;
    prevOrthogonalDelta = orthogonalDelta;

    // Implements an exponentially weighted moving average (EWMA) filter (= exponential smoothing)
    // Smoothing factor is approximated each event to achieve a chosen filter time constant
    qreal smoothingFactor = std::min(frameTime / (1000 * m_filterTimeConstant), 0.8);
    m_yVelocity = m_yVelocity + smoothingFactor * (framePrimaryDelta / frameTime - m_yVelocity);
    m_xVelocity = m_xVelocity + smoothingFactor * (frameOrthogonalDelta / frameTime - m_xVelocity);
    m_totalSquaredVelocity = m_yVelocity * m_yVelocity + m_xVelocity * m_xVelocity;
    Q_EMIT velocityChanged();
}

void MobileTaskSwitcherState::processTouchPositionChanged(qreal primaryDelta, qreal orthogonalDelta)
{
    calculateFilteredVelocity(primaryDelta, orthogonalDelta);
    m_touchXPosition = orthogonalDelta;
    m_touchYPosition = primaryDelta;
    Q_EMIT touchPositionChanged();
}

qint64 MobileTaskSwitcherState::getElapsedTimeSinceStart()
{
    if (m_doubleClickTimer->isValid()) {
        return m_doubleClickTimer->elapsed();
    }
    return -1;
}

void MobileTaskSwitcherState::toggle()
{
    if (!m_effect) {
        return;
    }

    if (!m_effect->isRunning()) {
        restartDoubleClickTimer();
        activate();
    } else {
        deactivate(false);
    }
}

void MobileTaskSwitcherState::activate()
{
    if (effects->isScreenLocked()) {
        return;
    }

    m_effectState->setInProgress(false);
    invokeEffect();
}

void MobileTaskSwitcherState::deactivate(bool deactivateInstantly)
{
    if (!m_effect) {
        return;
    }

    const auto screens = effects->screens();
    for (const auto screen : screens) {
        if (QuickSceneView *view = m_effect->viewForScreen(screen)) {
            QMetaObject::invokeMethod(view->rootItem(), "hideAnimation");
        }
    }
    m_shutdownTimer->start(m_effect->animationTime(deactivateInstantly ? 0ms : 200ms));
}

void MobileTaskSwitcherState::realDeactivate()
{
    if (!m_effect || !m_effectState) {
        return;
    }

    m_effectState->setInProgress(false);
    setStatus(MobileTaskSwitcherState::Status::Inactive);
    m_effect->setRunning(false);
    setDBusState(false);
}

void MobileTaskSwitcherState::quickDeactivate()
{
    m_shutdownTimer->start(0);
}

void MobileTaskSwitcherState::setDBusState(bool active)
{
    QDBusMessage request = QDBusMessage::createMethodCall(QStringLiteral("org.kde.plasmashell"),
                                                          QStringLiteral("/Mobile"),
                                                          QStringLiteral("org.kde.plasmashell"),
                                                          QStringLiteral("setIsTaskSwitcherVisible"));
    request.setArguments({active});

    // this does not block, so it won't necessarily be called before the method returns
    QDBusConnection::sessionBus().send(request);
}

void MobileTaskSwitcherState::invokeEffect()
{
    setInitialTaskIndex(currentTaskIndex()); // TODO! this is only until the crashing bug is fixed and recency sorting is in
    m_effect->setRunning(true);
    setDBusState(true);
}
}
