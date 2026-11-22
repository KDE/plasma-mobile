// SPDX-FileCopyrightText: 2021 Vlad Zahorodnii <vlad.zahorodnii@kde.org>
// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-FileCopyrightText: 2024 Luis Büchi <luis.buechi@kdemail.net>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include <effect/effect.h>
#include <effect/effecthandler.h>
#include <effect/quickeffect.h>
#include <window.h>

#include <QElapsedTimer>
#include <QTimer>

#include "effecttouchborder.h"
#include "taskmodel.h"

namespace KWin
{

class MobileTaskSwitcherState : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool gestureEnabled READ gestureEnabled WRITE setGestureEnabled NOTIFY gestureEnabledChanged)

    Q_PROPERTY(bool gestureInProgress READ gestureInProgress NOTIFY gestureInProgressChanged)

    Q_PROPERTY(KWin::MobileTaskSwitcherState::Phase phase READ phase NOTIFY phaseChanged)
    Q_PROPERTY(bool closing READ isClosing NOTIFY phaseChanged)
    Q_PROPERTY(bool closingToHome READ isClosingToHome NOTIFY phaseChanged)
    Q_PROPERTY(bool launchingTask READ isLaunchingTask NOTIFY phaseChanged)
    Q_PROPERTY(bool taskDrawerOpened READ taskDrawerOpened NOTIFY taskDrawerOpenedChanged)

    Q_PROPERTY(KWin::TaskModel *taskModel READ taskModel CONSTANT)
    QML_ELEMENT

public:
    enum class Phase {
        Hidden, // Effect is not running
        Visible, // Shown: tracking a gesture, animating open, or opened
        ClosingToHome, // Animating away to the home screen
        LaunchingTask, // Animating into a task that was activated
    };
    Q_ENUM(Phase)

    MobileTaskSwitcherState(QObject *parent = nullptr);

    Q_INVOKABLE void init(KWin::QuickSceneEffect *parent);

    bool gestureEnabled() const;
    void setGestureEnabled(bool gestureEnabled);

    bool gestureInProgress() const;
    // whether the window is an app being shown, rather than the home screen
    Q_INVOKABLE bool isAppWindow(KWin::Window *window) const;

    Phase phase() const;
    bool taskDrawerOpened() const;
    bool isClosing() const;
    bool isClosingToHome() const;
    bool isLaunchingTask() const;

    // Whether is double tap
    Q_INVOKABLE bool isDoubleToggle() const;

    // Phase transitions requested by the QML side
    Q_INVOKABLE void openingFinished();
    Q_INVOKABLE void beginClosing(KWin::MobileTaskSwitcherState::Phase target);
    Q_INVOKABLE void cancelClosing();
    Q_INVOKABLE void closingFinished();
    Q_INVOKABLE void restartFromClosing();

    void setDBusState(bool active);

    TaskModel *taskModel() const;

public Q_SLOTS:
    void activate();
    void realDeactivate();
    void deactivate(bool deactivateInstantly);
    void toggle();

Q_SIGNALS:
    void gestureEnabledChanged();

    void activated();

    void gestureInProgressChanged();
    void phaseChanged();
    void taskDrawerOpenedChanged();

    // The touch of the gesture moved, relative to where it started (reported from KWin)
    void touchMoved(qreal x, qreal y);

private Q_SLOTS:
    void refreshBorders();

private:
    void invokeEffect();
    void setPhase(Phase phase);
    void setTaskDrawerOpened(bool taskDrawerOpened);

    bool m_gestureEnabled{false};
    EffectTouchBorderState *m_effectState{nullptr};
    EffectTouchBorder *m_border{nullptr};
    TaskModel *m_taskModel{nullptr};
    KWin::QuickSceneEffect *m_effect{nullptr};

    Phase m_phase = Phase::Hidden;
    bool m_taskDrawerOpened = false;

    QElapsedTimer m_toggleTimer;

    QTimer *m_shutdownTimer;
};

} // namespace KWin
