// SPDX-FileCopyrightText: 2021 Vlad Zahorodnii <vlad.zahorodnii@kde.org>
// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-FileCopyrightText: 2024 Luis Büchi <luis.buechi@kdemail.net>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "mobiletaskswitchereffect.h"

#include <QDBusConnection>
#include <QDBusMessage>
#include <QGuiApplication>
#include <QMetaObject>
#include <QQuickItem>
#include <window.h>

using namespace std::chrono_literals;

namespace KWin
{

MobileTaskSwitcherState::MobileTaskSwitcherState(QObject *parent)
    : QObject{parent}
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

    // Disable view caching for now - there is still background CPU usage from the KWin effect that makes it inefficient
    // m_effect->setViewCachingEnabled(true);

    // Connect signals
    connect(m_effect, &QuickSceneEffect::activated, this, &MobileTaskSwitcherState::activated);
    connect(this, &MobileTaskSwitcherState::gestureEnabledChanged, this, &MobileTaskSwitcherState::refreshBorders);
    connect(m_border, &EffectTouchBorder::touchPositionChanged, this, [this](qreal primaryDelta, qreal orthogonalDelta) {
        Q_EMIT touchMoved(orthogonalDelta, primaryDelta);
    });
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

bool MobileTaskSwitcherState::isAppWindow(KWin::Window *window) const
{
    // A minimized app can remain active until the shell receives focus
    return window && !window->isDesktop() && window->isShown();
}

MobileTaskSwitcherState::Phase MobileTaskSwitcherState::phase() const
{
    return m_phase;
}

void MobileTaskSwitcherState::setPhase(Phase phase)
{
    if (m_phase != phase) {
        m_phase = phase;
        Q_EMIT phaseChanged();
    }
}

bool MobileTaskSwitcherState::taskDrawerOpened() const
{
    return m_taskDrawerOpened;
}

void MobileTaskSwitcherState::setTaskDrawerOpened(bool taskDrawerOpened)
{
    if (m_taskDrawerOpened != taskDrawerOpened) {
        m_taskDrawerOpened = taskDrawerOpened;
        Q_EMIT taskDrawerOpenedChanged();
    }
}

bool MobileTaskSwitcherState::isClosing() const
{
    return m_phase == Phase::ClosingToHome || m_phase == Phase::LaunchingTask;
}

bool MobileTaskSwitcherState::isClosingToHome() const
{
    return m_phase == Phase::ClosingToHome;
}

bool MobileTaskSwitcherState::isLaunchingTask() const
{
    return m_phase == Phase::LaunchingTask;
}

void MobileTaskSwitcherState::openingFinished()
{
    if (m_phase == Phase::Visible) {
        setTaskDrawerOpened(true);
    }
}

void MobileTaskSwitcherState::beginClosing(Phase target)
{
    if (m_phase == Phase::Hidden || (target != Phase::ClosingToHome && target != Phase::LaunchingTask)) {
        return;
    }
    setPhase(target);
}

void MobileTaskSwitcherState::cancelClosing()
{
    if (isClosing()) {
        setPhase(Phase::Visible);
    }
}

void MobileTaskSwitcherState::closingFinished()
{
    // Stay in the closing phase until the effect has stopped, the last frame is still being shown
    setTaskDrawerOpened(false);
    deactivate(true);
}

void MobileTaskSwitcherState::restartFromClosing()
{
    // A new gesture took over while the switcher was closing
    setTaskDrawerOpened(false);
    setPhase(Phase::Visible);
}

TaskModel *MobileTaskSwitcherState::taskModel() const
{
    return m_taskModel;
}

bool MobileTaskSwitcherState::isDoubleToggle() const
{
    return m_toggleTimer.isValid() && m_toggleTimer.elapsed() < qApp->doubleClickInterval();
}

void MobileTaskSwitcherState::toggle()
{
    if (!m_effect) {
        return;
    }

    if (!m_effect->isRunning()) {
        m_toggleTimer.restart();
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
    setTaskDrawerOpened(false);
    m_effect->setRunning(false);
    setPhase(Phase::Hidden);
    setDBusState(false);
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
    m_shutdownTimer->stop();
    if (m_phase == Phase::Hidden) {
        setPhase(Phase::Visible);
    }
    m_effect->setRunning(true);
    setDBusState(true);
}
}
