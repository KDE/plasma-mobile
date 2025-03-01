// SPDX-FileCopyrightText: 2021 Vlad Zahorodnii <vlad.zahorodnii@kde.org>
// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-FileCopyrightText: 2024 Luis Büchi <luis.buechi@kdemail.net>
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
    Q_PROPERTY(bool gestureEnabled READ gestureEnabled WRITE setGestureEnabled NOTIFY gestureEnabledChanged)

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

    Q_PROPERTY(qint64 elapsedTimeSinceStart READ getElapsedTimeSinceStart)
    Q_PROPERTY(qint64 doubleClickInterval READ getDoubleClickInterval) // is there a better way than to forward this?

    Q_PROPERTY(TaskModel *taskModel READ taskModel CONSTANT)
    QML_ELEMENT

public:
    enum class Status {
        // TODO! I could (should?) re-add the activating and deactivating states again to match EffectTogglableState. could help with/tie into
        // currentlyBeingOpened and currentlyBeingClosed
        Inactive, // Task switcher is not fully showing
        Active, // Task switcher is active and gesture not in progress anymore
        Stopped // When is this the case?
    };
    Q_ENUM(Status)

    MobileTaskSwitcherState(QObject *parent = nullptr);

    Q_INVOKABLE void init(KWin::QuickSceneEffect *parent);

    bool gestureEnabled() const;
    void setGestureEnabled(bool gestureEnabled);

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

    Status status() const;
    void setStatus(Status status);

    int currentTaskIndex() const;
    void setCurrentTaskIndex(int newTaskIndex);

    int initialTaskIndex() const;
    void setInitialTaskIndex(int newTaskIndex);

    void restartDoubleClickTimer();

    int animationDuration() const;
    void setDBusState(bool active);

    TaskModel *taskModel() const;

public Q_SLOTS:
    void processTouchPositionChanged(qreal primaryPosition, qreal orthogonalPosition);

    void activate();
    void realDeactivate();
    void deactivate(bool deactivateInstantly);
    void quickDeactivate();
    void toggle();

Q_SIGNALS:
    void gestureEnabledChanged();

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

private Q_SLOTS:
    void refreshBorders();

private:
    void invokeEffect();

    bool m_gestureEnabled{false};
    EffectTouchBorderState *m_effectState{nullptr};
    EffectTouchBorder *m_border{nullptr};
    TaskModel *m_taskModel{nullptr};
    KWin::QuickSceneEffect *m_effect{nullptr};

    Status m_status = Status::Inactive;
    bool m_gestureInProgress = false;

    int m_currentTaskIndex;
    int m_initialTaskIndex;

    void clearVelocityFilter();
    void calculateFilteredVelocity(qreal primaryPosition, qreal orthogonalPosition);
    qint64 getElapsedTimeSinceStart();

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

    QElapsedTimer *m_doubleClickTimer;
    qint64 getDoubleClickInterval() const
    {
        return qApp->doubleClickInterval();
    }

    QTimer *m_shutdownTimer;
};

} // namespace KWin
