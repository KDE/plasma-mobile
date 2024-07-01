// SPDX-FileCopyrightText: 2021 Vlad Zahorodnii <vlad.zahorodnii@kde.org>
// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-FileCopyrightText: 2024 Luis Büchi <luis.buechi@server23.cc>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include <effect/effect.h>
#include <effect/effecthandler.h>
#include <effect/quickeffect.h>
#include <window.h>

#include <span>

#include <QAction>
#include <QElapsedTimer>
#include <QKeySequence>
#include <QTimer>

#include <KGlobalAccel>
#include <KLocalizedString>

#include "effecttouchborder.h"
#include "taskfiltermodel.h"
#include "taskmodel.h"

namespace KWin
{

class MobileTaskSwitcherState : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool wasInActiveTask READ wasInActiveTask WRITE setWasInActiveTask NOTIFY wasInActiveTaskChanged)
    Q_PROPERTY(int currentTaskIndex READ currentTaskIndex WRITE setCurrentTaskIndex NOTIFY currentTaskIndexChanged)
    Q_PROPERTY(int initialTaskIndex READ initialTaskIndex WRITE setInitialTaskIndex NOTIFY initialTaskIndexChanged)

    Q_PROPERTY(qreal touchXPosition READ touchXPosition NOTIFY touchPositionChanged)
    Q_PROPERTY(qreal touchYPosition READ touchYPosition NOTIFY touchPositionChanged)

    Q_PROPERTY(qreal xVelocity READ xVelocity NOTIFY velocityChanged)
    Q_PROPERTY(qreal yVelocity READ yVelocity NOTIFY velocityChanged)
    Q_PROPERTY(qreal totalSquaredVelocity READ totalSquaredVelocity NOTIFY velocityChanged)
    Q_PROPERTY(qreal flickVelocityThreshold READ flickVelocityThreshold NOTIFY flickVelocityThresholdChanged)

    Q_PROPERTY(qreal xPosition READ xPosition WRITE setXPosition NOTIFY xPositionChanged)
    Q_PROPERTY(qreal yPosition READ yPosition WRITE setYPosition NOTIFY yPositionChanged)

    Q_PROPERTY(bool gestureInProgress READ gestureInProgress NOTIFY gestureInProgressChanged)
    Q_PROPERTY(Status status READ status WRITE setStatus NOTIFY statusChanged)

public:
    enum class Status {
        // TODO! I could (should?) re-add the activating and deactivating states again to match EffectTogglableState. could help with/tie into
        // currentlyBeingOpened and currentlyBeingClosed
        Inactive, // Task switcher is not fully showing
        Active, // Task switcher is active and gesture not in progress anymore
        Stopped // When is this the case?
    };
    Q_ENUM(Status)

    MobileTaskSwitcherState(EffectTouchBorderState *effectState);

    bool gestureInProgress() const;
    void setGestureInProgress(bool gestureInProgress);
    bool wasInActiveTask() const;
    void setWasInActiveTask(bool wasInActiveTask);
    Q_INVOKABLE void updateWasInActiveTask(KWin::Window *window);

    qreal touchXPosition() const;
    qreal touchYPosition() const;
    qreal xVelocity() const;
    qreal yVelocity() const;
    qreal totalSquaredVelocity() const;
    qreal flickVelocityThreshold() const;
    void setFlickVelocityThreshold(qreal flickVelocityThreshold);

    qreal xPosition() const;
    void setXPosition(qreal positionX);
    qreal yPosition() const;
    void setYPosition(qreal positionY);

    void setStatus(Status status);
    Status status() const
    {
        return m_status;
    }

    void setCurrentTaskIndex(int newTaskIndex);
    int currentTaskIndex() const
    {
        return m_currentTaskIndex;
    }

    void setInitialTaskIndex(int newTaskIndex);
    int initialTaskIndex() const
    {
        return m_initialTaskIndex;
    }

public Q_SLOTS:
    void processTouchPositionChanged(qreal primaryPosition, qreal orthogonalPosition);

Q_SIGNALS:
    void activated();
    void deactivated();

    void gestureInProgressChanged();
    void statusChanged();

    void wasInActiveTaskChanged();

    void currentTaskIndexChanged();
    void initialTaskIndexChanged();

    void touchPositionChanged();

    void velocityChanged();
    void flickVelocityThresholdChanged();

    void xPositionChanged();
    void yPositionChanged();

private:
    Status m_status = Status::Inactive;
    EffectTouchBorderState *m_effectState;
    bool m_gestureInProgress = false;

    int m_currentTaskIndex;
    int m_initialTaskIndex;

    void clearVelocityFilter();
    void calculateFilteredVelocity(qreal primaryPosition, qreal orthogonalPosition);

    // velocities in (logical) pixels/msec
    QElapsedTimer m_frameTimer;
    qreal m_flickVelocityThreshold = 0.5 * 0.5; // squared because total velocity is kept as a square
    qreal m_filterTimeConstant = 0.03; // time constant of velocity filter

    qreal m_touchXPosition;
    qreal m_touchYPosition;
    qreal m_xVelocity = 0;
    qreal m_yVelocity = 0;
    // Using the square of velocity for the total (2-axis) because we just need it
    // for one threshold comparison and we skip having to calculate the square root
    qreal m_totalSquaredVelocity;

    // Positions of the task switcher effect itself
    qreal m_xPosition = 0;
    qreal m_yPosition = 0;

    bool m_wasInActiveTask;
};

class MobileTaskSwitcherEffect : public QuickSceneEffect
{
    Q_OBJECT

public:
    enum class Status { Inactive, Activating, Deactivating, Active };
    MobileTaskSwitcherEffect();
    ~MobileTaskSwitcherEffect() override;

    int animationDuration() const;
    void setAnimationDuration(int duration);

    int requestedEffectChainPosition() const override;
    bool borderActivated(ElectricBorder border) override;
    void reconfigure(ReconfigureFlags flags) override;
    void grabbedKeyboardEvent(QKeyEvent *keyEvent) override;

    void setDBusState(bool active);

public Q_SLOTS:
    void activate();
    void realDeactivate();
    void deactivate(bool deactivateInstantly);
    void quickDeactivate();
    void toggle();

Q_SIGNALS:
    void animationDurationChanged();
    void gestureInProgressChanged();

private:
    void invokeEffect();

    EffectTouchBorderState *const m_effectState;
    MobileTaskSwitcherState *const m_taskSwitcherState;
    TaskModel *const m_taskModel;
    EffectTouchBorder *const m_border;
    QList<int> m_borderActivate = {ElectricBorder::ElectricBottom};

    std::unique_ptr<QAction> m_toggleAction;
    QList<QKeySequence> m_toggleShortcut;

    QTimer *m_shutdownTimer;

    int m_animationDuration = 400;
};

} // namespace KWin
