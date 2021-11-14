/*
 * Copyright (C) 2015 Canonical Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#pragma once

#include <damper_p.h>
#include <ucswipearea_p.h>

#include <QtQuick/private/qquickitem_p.h>

// Information about an active touch point
struct ActiveTouchInfo {
    ActiveTouchInfo()
        : id(-1)
        , startTime(-1)
    {
    }
    bool isValid() const
    {
        return id != -1;
    }
    void reset()
    {
        id = -1;
    }
    int id;
    qint64 startTime;
};
class ActiveTouchesInfo
{
public:
    ActiveTouchesInfo(const SharedTimeSource &timeSource);
    void update(QTouchEvent *event);
    qint64 touchStartTime(int id);
    bool isEmpty() const
    {
        return m_touchInfoPool.isEmpty();
    }
    qint64 mostRecentStartTime();
    SharedTimeSource m_timeSource;

private:
    void addTouchPoint(int touchId);
    void removeTouchPoint(int touchId);
    QString toString();

    Pool<ActiveTouchInfo> m_touchInfoPool;
};

class UCSwipeAreaStatusListener;
class UCSwipeAreaPrivate : public QQuickItemPrivate
{
    Q_DECLARE_PUBLIC(UCSwipeArea)

    Q_ENUMS(Status)
public:
    UCSwipeAreaPrivate();
    void init();
    static UCSwipeAreaPrivate *get(UCSwipeArea *area)
    {
        return area->d_func();
    }

    void setMaxTime(int value);

    void setCompositionTime(int value);

    // Replaces the existing Timer with the given one.
    //
    // Useful for providing a fake timer when testing.
    void setRecognitionTimer(AbstractTimer *timer);

    // Useful for testing, where a fake time source can be supplied
    void setTimeSource(const SharedTimeSource &timeSource);

    // Describes the state of the directional drag gesture.
    enum Status {
        // Waiting for a new touch point to land on this area. No gesture is being processed
        // or tracked.
        WaitingForTouch,

        // A touch point has landed on this area but it's not know yet whether it is
        // performing a drag in the correct direction.
        // If it's decided that the touch point is not performing a directional drag gesture,
        // it will be rejected/ignored and status will return to WaitingForTouch.
        Undecided, // Recognizing,

        // There's a touch point in this area and it performed a drag in the correct
        // direction.
        //
        // Once recognized, the gesture state will move back to WaitingForTouch only once
        // that touch point ends. The gesture will remain in the Recognized state even if
        // the touch point starts moving in other directions or halts.
        Recognized,
    };

    void touchEvent_absent(QTouchEvent *event);
    void touchEvent_undecided(QTouchEvent *event);
    void touchEvent_recognized(QTouchEvent *event);
    bool movingInRightDirection() const;
    bool movedFarEnoughAlongGestureAxis() const;
    bool isPastMaxDistance() const;
    const QTouchEvent::TouchPoint *fetchTargetTouchPoint(QTouchEvent *event);
    void setStatus(Status newStatus);
    void updatePosition(const QPointF &point);
    void setPublicScenePos(const QPointF &point);
    bool isWithinTouchCompositionWindow();
    void updateSceneDirectionVector();
    // returns the scalar projection between the given vector (in scene coordinates)
    // and m_sceneDirectionVector
    qreal projectOntoDirectionVector(const QPointF &sceneVector) const;
    void touchOwnershipEvent(TouchOwnershipEvent *event);
    void unownedTouchEvent(UnownedTouchEvent *event);
    void unownedTouchEvent_undecided(UnownedTouchEvent *unownedTouchEvent);
    void watchPressedTouchPoints(const QList<QTouchEvent::TouchPoint> &touchPoints);
    bool recognitionIsDisabled() const;
    bool sanityCheckRecognitionProperties();
    void setDistanceThreshold(qreal value);
    void setPixelsPerMm(qreal pixelsPerMm);
    QString objectName() const
    {
        return q_func()->objectName();
    }

    // manage status change listeners
    void addStatusChangeListener(UCSwipeAreaStatusListener *listener);
    void removeStatusChangeListener(UCSwipeAreaStatusListener *listener);

    QPointF startScenePos;
    // The touch position exposed in the public API.
    // It only starts to move once the gesture gets recognized.
    QPointF publicScenePos;
    // A movement damper is used in some of the gesture recognition calculations
    // to get rid of noise or small oscillations in the touch position.
    DampedPointF dampedScenePos;
    QPointF previousDampedScenePos;
    // Unit vector in scene coordinates describing the direction of the gesture recognition
    QPointF sceneDirectionVector;
    SharedTimeSource timeSource;
    ActiveTouchesInfo activeTouches;

    // status change listeners
    QList<UCSwipeAreaStatusListener *> statusChangeListeners;

    AbstractTimer *recognitionTimer;

    // How far a touch point has to move from its initial position along the gesture axis in order
    // for it to be recognized as a directional drag.
    qreal distanceThreshold;
    qreal distanceThresholdSquared; // it's pow(distanceThreshold, 2)
    // Maximum distance the gesture can go without crossing the axis-aligned distance threshold
    qreal maxDistance;
    qreal sceneDistance;

    int touchId;
    // Maximum time (in milliseconds) the gesture can take to go beyond the distance threshold
    int maxTime;
    // Maximum time (in milliseconds) after the start of a given touch point where
    // subsequent touch starts are grouped with the first one into an N-touches gesture
    // (e.g. a two-fingers tap or drag).
    int compositionTime;

    // The current status of the directional drag gesture area.
    Status status;
    UCSwipeArea::Direction direction;

    bool immediateRecognition;
    bool grabGesture;
};

class UCSwipeAreaStatusListener
{
public:
    virtual void swipeStatusChanged(UCSwipeAreaPrivate::Status /*old*/, UCSwipeAreaPrivate::Status /*new*/)
    {
    }
};
