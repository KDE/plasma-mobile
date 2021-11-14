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

#include "ucswipearea_p_p.h"

#include <QtCore/QDebug>
#include <QtCore/QtMath>
#include <QtGui/QScreen>
#include <QtQuick/QQuickWindow>
#include <QtQuick/private/qquickwindow_p.h>

#include "touchownershipevent_p.h"
#include "touchregistry_p.h"
#include "unownedtouchevent_p.h"

Q_LOGGING_CATEGORY(ucSwipeArea, "lomiri.components.SwipeArea", QtMsgType::QtWarningMsg)
Q_LOGGING_CATEGORY(ucActiveTouchInfo, "lomiri.components.SwipeArea.ActiveTouchInfo", QtMsgType::QtWarningMsg)

#define SA_TRACE(params) qCDebug(ucSwipeArea).nospace() << "[SwipeArea(" << qPrintable(objectName()) << ")] " << params
#define TI_TRACE(params) qCDebug(ucActiveTouchInfo).nospace() << "[ActiveTouchInfo] " << params

namespace
{
const char *statusToString(UCSwipeAreaPrivate::Status status)
{
    if (status == UCSwipeAreaPrivate::WaitingForTouch) {
        return "WaitingForTouch";
    } else if (status == UCSwipeAreaPrivate::Undecided) {
        return "Undecided";
    } else {
        return "Recognized";
    }
}

QString touchPointStateToString(Qt::TouchPointState state)
{
    switch (state) {
    case Qt::TouchPointPressed:
        return QStringLiteral("pressed");
    case Qt::TouchPointMoved:
        return QStringLiteral("moved");
    case Qt::TouchPointStationary:
        return QStringLiteral("stationary");
    case Qt::TouchPointReleased:
        return QStringLiteral("released");
    default:
        return QStringLiteral("INVALID_STATE");
    }
}

QString touchEventToString(const QTouchEvent *ev)
{
    QString message;

    switch (ev->type()) {
    case QEvent::TouchBegin:
        message.append(QStringLiteral("TouchBegin "));
        break;
    case QEvent::TouchUpdate:
        message.append(QStringLiteral("TouchUpdate "));
        break;
    case QEvent::TouchEnd:
        message.append(QStringLiteral("TouchEnd "));
        break;
    case QEvent::TouchCancel:
        message.append(QStringLiteral("TouchCancel "));
        break;
    default:
        message.append(QStringLiteral("INVALID_TOUCH_EVENT_TYPE "));
    }

    Q_FOREACH (const QTouchEvent::TouchPoint &touchPoint, ev->touchPoints()) {
        message.append(QStringLiteral("(id:%1, state:%2, scenePos:(%3,%4)) ")
                           .arg(touchPoint.id())
                           .arg(touchPointStateToString(touchPoint.state()))
                           .arg(touchPoint.scenePos().x())
                           .arg(touchPoint.scenePos().y()));
    }

    return message;
}

} // namespace {

class Direction
{
public:
    static bool isHorizontal(UCSwipeArea::Direction type)
    {
        return type == UCSwipeArea::Leftwards || type == UCSwipeArea::Rightwards || type == UCSwipeArea::Horizontal;
    }

    static bool isVertical(UCSwipeArea::Direction type)
    {
        return type == UCSwipeArea::Upwards || type == UCSwipeArea::Downwards || type == UCSwipeArea::Vertical;
    }

    static bool isPositive(UCSwipeArea::Direction type)
    {
        return type == UCSwipeArea::Rightwards || type == UCSwipeArea::Downwards || type == UCSwipeArea::Horizontal || type == UCSwipeArea::Vertical;
    }
};
/*!
 * \qmltype SwipeArea
 * \instantiates UCSwipeArea
 * \inherits Item
 * \inqmlmodule Lomiri.Components
 * \since Lomiri.Components 1.3
 * \ingroup lomiri-gestures
 * \brief An area which detects axis-aligned single-finger drag gestures.
 *
 * The component can be used to detect gestures of a certain direction, and can
 * grab gestures started on a component placed behind of the SwipeArea.
 * The gesture is detected on the SwipeArea, therefore the size must be
 * chosen carefully so it can properly detect the gesture.
 *
 * The gesture direction is specified by the \l direction property. The recognized
 * and captured gesture is reported through the \l dragging property, which becomes
 * \c true when the gesture is detected. If there was a component under the
 * SwipeArea, the gesture will be cancelled on that component.
 *
 * The drag recognition is performed within the component area in the specified
 * direction. If the drag deviates too much from this, recognition will fail,
 * as well as if the drag or the flick is too short. Once the drag is
 * intercepted, the gesture will be followed even after it leaves the detection area.
 *
 * Example:
 * \qml
 * import QtQuick 2.4
 * import Lomiri.Components 1.3
 *
 * MainView {
 *     width: units.gu(40)
 *     height: units.gu(70)
 *
 *     Page {
 *         title: "SwipeArea sample"
 *         SwipeArea {
 *             anchors {
 *                 left: parent.left
 *                 right: parent.right
 *                 bottom: parent.bottom
 *             }
 *             height: units.gu(5)
 *             direction: SwipeArea.Upwards
 *             Label {
 *                 text: "Drag upwards"
 *                 anchors {
 *                     centerIn: parent
 *                     verticalOffset: parent.dragging ? parent.distance : 0
 *                 }
 *             }
 *         }
 *     }
 * }
 * \endqml
 * \note When used with a Flickable (or ListView, GridView) always put the
 * SwipeArea next to the Flickable as sibling.
 */
UCSwipeArea::UCSwipeArea(QQuickItem *parent)
    : QQuickItem(*(new UCSwipeAreaPrivate), parent)
{
    Q_D(UCSwipeArea);
    d->init();
}

/*!
 * \qmlproperty enum SwipeArea::direction
 * The direction in which the gesture should move in order to be recognized.
 * \table
 * \header
 *  \li Direction
 *  \li Description
 * \row
 *  \li Rightwards
 *  \li Along the positive direction of the X axis
 * \row
 *  \li Leftwards
 *  \li Along the negative direction of the X axis
 * \row
 *  \li Downwards
 *  \li Along the positive direction of the Y axis
 * \row
 *  \li Upwards
 *  \li Along the negative direction of the Y axis
 * \row
 *  \li Horizontal
 *  \li Along the X axis, in any direction
 * \row
 *  \li Vertical
 *  \li Along the Y axis, in any direction
 * \endtable
 */
UCSwipeArea::Direction UCSwipeArea::direction() const
{
    Q_D(const UCSwipeArea);
    return d->direction;
}

void UCSwipeArea::setDirection(Direction direction)
{
    Q_D(UCSwipeArea);
    if (direction != d->direction) {
        d->direction = direction;
        Q_EMIT directionChanged(d->direction);
    }
}

void UCSwipeAreaPrivate::setDistanceThreshold(qreal value)
{
    if (distanceThreshold != value) {
        distanceThreshold = value;
        distanceThresholdSquared = distanceThreshold * distanceThreshold;
    }
}

void UCSwipeAreaPrivate::setCompositionTime(int value)
{
    compositionTime = value;
}

void UCSwipeAreaPrivate::setMaxTime(int value)
{
    if (maxTime != value) {
        maxTime = value;
        recognitionTimer->setInterval(maxTime);
    }
}

void UCSwipeAreaPrivate::setRecognitionTimer(AbstractTimer *timer)
{
    int interval = 0;
    bool timerWasRunning = false;
    bool wasSingleShot = false;
    Q_Q(UCSwipeArea);

    // can be null when called from the constructor
    if (recognitionTimer) {
        wasSingleShot = recognitionTimer->isSingleShot();
        interval = recognitionTimer->interval();
        timerWasRunning = recognitionTimer->isRunning();
        if (recognitionTimer->parent() == q) {
            delete recognitionTimer;
        }
    }

    recognitionTimer = timer;
    timer->setInterval(interval);
    timer->setSingleShot(wasSingleShot);
    QObject::connect(timer, &AbstractTimer::timeout, q, &UCSwipeArea::rejectGesture);
    if (timerWasRunning) {
        recognitionTimer->start();
    }
}

void UCSwipeAreaPrivate::setTimeSource(const SharedTimeSource &timeSource)
{
    this->timeSource = timeSource;
    activeTouches.m_timeSource = timeSource;
}

/*!
 * \qmlproperty real SwipeArea::distance
 * \readonly
 * The property holds the distance of the swipe from the beginning of the gesture
 * recognition to the current touch position.
 */
qreal UCSwipeArea::distance() const
{
    Q_D(const UCSwipeArea);
    return d->sceneDistance;
}

/*!
 * \qmlproperty point SwipeArea::touchPosition
 * \readonly
 * Position of the touch point performing the drag relative to this item.
 */
QPointF UCSwipeArea::touchPosition() const
{
    Q_D(const UCSwipeArea);
    return mapFromScene(d->publicScenePos);
}

/*!
 * \qmlproperty bool SwipeArea::dragging
 * \readonly
 * Reports whether a drag gesture is taking place.
 */
bool UCSwipeArea::dragging() const
{
    Q_D(const UCSwipeArea);
    return d->status == UCSwipeAreaPrivate::Recognized;
}

/*!
 * \qmlproperty bool SwipeArea::pressed
 * \readonly
 * Reports whether the drag area is pressed.
 */
bool UCSwipeArea::pressed() const
{
    Q_D(const UCSwipeArea);
    return d->status != UCSwipeAreaPrivate::WaitingForTouch;
}

/*!
 * \qmlproperty bool SwipeArea::immediateRecognition
 * Drives whether the gesture should be recognized as soon as the touch lands on
 * the area. With this property set it will work the same way as a MultiPointTouchArea,
 *
 * Defaults to false. In most cases this should not be set.
 */
bool UCSwipeArea::immediateRecognition() const
{
    Q_D(const UCSwipeArea);
    return d->immediateRecognition;
}

void UCSwipeArea::setImmediateRecognition(bool enabled)
{
    Q_D(UCSwipeArea);
    if (d->immediateRecognition != enabled) {
        d->immediateRecognition = enabled;
        Q_EMIT immediateRecognitionChanged(enabled);
    }
}

/*!
 * \qmlproperty bool SwipeArea::grabGesture
 * If true, any gestures will be grabbed and owned by the SwipeArea as usual.
 * If false, gestures will still be reported, but events may be grabbed by
 * another Qml object.
 *
 * Defaults to true. In most cases this should not be unset.
 */
bool UCSwipeArea::grabGesture() const
{
    Q_D(const UCSwipeArea);
    return d->grabGesture;
}

void UCSwipeArea::setGrabGesture(bool enabled)
{
    Q_D(UCSwipeArea);
    if (d->grabGesture == enabled) {
        return;
    }

    d->grabGesture = enabled;

    if (!d->grabGesture && d->status == UCSwipeAreaPrivate::Undecided) {
        TouchRegistry::instance()->removeCandidateOwnerForTouch(d->touchId, this);
        // We still wanna know when it ends for keeping the composition time window up-to-date
        TouchRegistry::instance()->addTouchWatcher(d->touchId, this);
    }

    Q_EMIT grabGestureChanged(enabled);
}

bool UCSwipeArea::event(QEvent *event)
{
    Q_D(UCSwipeArea);
    if (event->type() == TouchOwnershipEvent::touchOwnershipEventType()) {
        d->touchOwnershipEvent(static_cast<TouchOwnershipEvent *>(event));
        return true;
    } else if (event->type() == UnownedTouchEvent::unownedTouchEventType()) {
        d->unownedTouchEvent(static_cast<UnownedTouchEvent *>(event));
        return true;
    } else {
        return QQuickItem::event(event);
    }
}

void UCSwipeAreaPrivate::touchOwnershipEvent(TouchOwnershipEvent *event)
{
    Q_Q(UCSwipeArea);
    if (event->gained()) {
        QVector<int> ids;
        ids.append(event->touchId());
        SA_TRACE("grabbing touch");
        q->grabTouchPoints(ids);
    } else {
        // We still wanna know when it ends for keeping the composition time window up-to-date
        TouchRegistry::instance()->addTouchWatcher(touchId, q);

        setStatus(WaitingForTouch);
    }
}

void UCSwipeAreaPrivate::unownedTouchEvent(UnownedTouchEvent *unownedTouchEvent)
{
    Q_Q(UCSwipeArea);
    QTouchEvent *event = unownedTouchEvent->touchEvent();

    Q_ASSERT(!event->touchPointStates().testFlag(Qt::TouchPointPressed));

    SA_TRACE("Unowned " << timeSource->msecsSinceReference() << " " << qPrintable(touchEventToString(event)));

    switch (status) {
    case WaitingForTouch:
        // do nothing
        break;
    case Undecided:
        Q_ASSERT(q->isEnabled() && q->isVisible());
        unownedTouchEvent_undecided(unownedTouchEvent);
        break;
    default: // Recognized:
        if (!grabGesture) {
            // Treat unowned event as if we owned it, but we are really just watching it
            touchEvent_recognized(event);
        }
        break;
    }

    activeTouches.update(event);
}

void UCSwipeAreaPrivate::unownedTouchEvent_undecided(UnownedTouchEvent *unownedTouchEvent)
{
    Q_Q(UCSwipeArea);
    const QTouchEvent::TouchPoint *touchPoint = fetchTargetTouchPoint(unownedTouchEvent->touchEvent());
    if (!touchPoint) {
        qCritical() << "UCSwipeArea[status=Undecided]: touch " << touchId
                    << "missing from UnownedTouchEvent without first reaching state Qt::TouchPointReleased. "
                       "Considering it as released.";

        TouchRegistry::instance()->removeCandidateOwnerForTouch(touchId, q);
        setStatus(WaitingForTouch);
        return;
    }

    const QPointF &touchScenePosition = touchPoint->scenePos();

    if (touchPoint->state() == Qt::TouchPointReleased) {
        // touch has ended before recognition concluded
        SA_TRACE("Touch has ended before recognition concluded");
        TouchRegistry::instance()->removeCandidateOwnerForTouch(touchId, q);
        setStatus(WaitingForTouch);
        return;
    }

    previousDampedScenePos.setX(dampedScenePos.x());
    previousDampedScenePos.setY(dampedScenePos.y());
    dampedScenePos.update(touchScenePosition);

    if (!movingInRightDirection()) {
        SA_TRACE("Rejecting gesture because touch point is moving in the wrong direction.");
        TouchRegistry::instance()->removeCandidateOwnerForTouch(touchId, q);
        // We still wanna know when it ends for keeping the composition time window up-to-date
        TouchRegistry::instance()->addTouchWatcher(touchId, q);
        setStatus(WaitingForTouch);
        return;
    }

    if (isWithinTouchCompositionWindow()) {
        // There's still time for some new touch to appear and ruin our party as it would be combined
        // with our touchId one and therefore deny the possibility of a single-finger gesture.
        SA_TRACE("Sill within composition window. Let's wait more.");
        return;
    }

    if (movedFarEnoughAlongGestureAxis()) {
        if (grabGesture) {
            TouchRegistry::instance()->requestTouchOwnership(touchId, q);
        }
        setStatus(Recognized);
        updatePosition(touchScenePosition);
    } else if (isPastMaxDistance()) {
        SA_TRACE("Rejecting gesture because it went farther than maxDistance without getting recognized.");
        TouchRegistry::instance()->removeCandidateOwnerForTouch(touchId, q);
        // We still wanna know when it ends for keeping the composition time window up-to-date
        TouchRegistry::instance()->addTouchWatcher(touchId, q);
        setStatus(WaitingForTouch);
    } else {
        SA_TRACE("Didn't move far enough yet. Let's wait more.");
    }
}

void UCSwipeArea::touchEvent(QTouchEvent *event)
{
    // FIXME: Consider when more than one touch starts in the same event (although it's not possible
    //       with Mir's android-input). Have to track them all. Consider it a plus/bonus.

    Q_D(UCSwipeArea);
    SA_TRACE(d->timeSource->msecsSinceReference() << " " << qPrintable(touchEventToString(event)));

    if (!isEnabled() || !isVisible()) {
        QQuickItem::touchEvent(event);
        return;
    }

    switch (d->status) {
    case UCSwipeAreaPrivate::WaitingForTouch:
        d->touchEvent_absent(event);
        break;
    case UCSwipeAreaPrivate::Undecided:
        d->touchEvent_undecided(event);
        break;
    default: // Recognized:
        d->touchEvent_recognized(event);
        break;
    }

    d->activeTouches.update(event);
}

void UCSwipeAreaPrivate::touchEvent_absent(QTouchEvent *event)
{
    // FIXME: accept/reject is for the whole event, not per touch id. See how that affects us.

    if (!event->touchPointStates().testFlag(Qt::TouchPointPressed)) {
        // Nothing to see here. No touch starting in this event.
        return;
    }

    // to be proven wrong, if that's the case
    bool allGood = true;

    if (isWithinTouchCompositionWindow()) {
        // too close to the last touch start. So we consider them as starting roughly at the same time.
        // Can't be a single-touch gesture.
        SA_TRACE("A new touch point came in but we're still within time composition window. Ignoring it.");
        allGood = false;
    }

    const QList<QTouchEvent::TouchPoint> &touchPoints = event->touchPoints();

    const QTouchEvent::TouchPoint *newTouchPoint = nullptr;
    for (int i = 0; i < touchPoints.count() && allGood; ++i) {
        const QTouchEvent::TouchPoint &touchPoint = touchPoints.at(i);
        if (touchPoint.state() == Qt::TouchPointPressed) {
            if (newTouchPoint) {
                // more than one touch starting in this QTouchEvent. Can't be a single-touch gesture
                allGood = false;
            } else {
                // that's our candidate
                newTouchPoint = &touchPoint;
            }
        }
    }

    if (allGood) {
        allGood = sanityCheckRecognitionProperties();
        if (!allGood) {
            qWarning(
                "UCSwipeArea: recognition properties are wrongly set. Gesture recognition"
                " is impossible");
        }
    }

    if (allGood) {
        Q_ASSERT(newTouchPoint);
        Q_Q(UCSwipeArea);

        startScenePos = newTouchPoint->scenePos();
        touchId = newTouchPoint->id();
        dampedScenePos.reset(startScenePos);
        updatePosition(startScenePos);

        updateSceneDirectionVector();

        if (recognitionIsDisabled()) {
            // Behave like a dumb TouchArea
            SA_TRACE("Gesture recognition is disabled. Requesting touch ownership immediately.");
            setStatus(Recognized);
            if (grabGesture) {
                TouchRegistry::instance()->requestTouchOwnership(touchId, q);
                event->accept();
            } else {
                watchPressedTouchPoints(touchPoints);
                event->ignore();
            }
        } else {
            // just monitor the touch points for now.
            if (grabGesture) {
                TouchRegistry::instance()->addCandidateOwnerForTouch(touchId, q);
            } else {
                watchPressedTouchPoints(touchPoints);
            }

            setStatus(Undecided);
            // Let the item below have it. We will monitor it and grab it later if a gesture
            // gets recognized.
            event->ignore();
        }
    } else {
        watchPressedTouchPoints(touchPoints);
        event->ignore();
    }
}

void UCSwipeAreaPrivate::touchEvent_undecided(QTouchEvent *event)
{
    Q_ASSERT(fetchTargetTouchPoint(event) == nullptr);

    // We're not interested in new touch points. We already have our candidate (touchId).
    // But we do want to know when those new touches end for keeping the composition time
    // window up-to-date
    event->ignore();
    watchPressedTouchPoints(event->touchPoints());

    if (event->touchPointStates().testFlag(Qt::TouchPointPressed) && isWithinTouchCompositionWindow()) {
        // multi-finger drags are not accepted
        SA_TRACE("Multi-finger drags are not accepted");

        Q_Q(UCSwipeArea);
        TouchRegistry::instance()->removeCandidateOwnerForTouch(touchId, q);
        // We still wanna know when it ends for keeping the composition time window up-to-date
        TouchRegistry::instance()->addTouchWatcher(touchId, q);

        setStatus(WaitingForTouch);
    }
}

void UCSwipeAreaPrivate::touchEvent_recognized(QTouchEvent *event)
{
    const QTouchEvent::TouchPoint *touchPoint = fetchTargetTouchPoint(event);

    if (!touchPoint) {
        qCritical() << "UCSwipeArea[status=Recognized]: touch " << touchId
                    << "missing from QTouchEvent without first reaching state Qt::TouchPointReleased. "
                       "Considering it as released.";
        setStatus(WaitingForTouch);
    } else {
        updatePosition(touchPoint->scenePos());

        if (touchPoint->state() == Qt::TouchPointReleased) {
            setStatus(WaitingForTouch);
        }
    }
}

void UCSwipeAreaPrivate::watchPressedTouchPoints(const QList<QTouchEvent::TouchPoint> &touchPoints)
{
    Q_Q(UCSwipeArea);
    for (int i = 0; i < touchPoints.count(); ++i) {
        const QTouchEvent::TouchPoint &touchPoint = touchPoints.at(i);
        if (touchPoint.state() == Qt::TouchPointPressed) {
            TouchRegistry::instance()->addTouchWatcher(touchPoint.id(), q);
        }
    }
}

bool UCSwipeAreaPrivate::recognitionIsDisabled() const
{
    return immediateRecognition || (distanceThreshold <= 0 && compositionTime <= 0);
}

bool UCSwipeAreaPrivate::sanityCheckRecognitionProperties()
{
    return recognitionIsDisabled() || (distanceThreshold < maxDistance && compositionTime < maxTime);
}

const QTouchEvent::TouchPoint *UCSwipeAreaPrivate::fetchTargetTouchPoint(QTouchEvent *event)
{
    const QList<QTouchEvent::TouchPoint> &touchPoints = event->touchPoints();
    const QTouchEvent::TouchPoint *touchPoint = 0;
    for (int i = 0; i < touchPoints.size(); ++i) {
        if (touchPoints.at(i).id() == touchId) {
            touchPoint = &touchPoints.at(i);
            break;
        }
    }
    return touchPoint;
}

bool UCSwipeAreaPrivate::movingInRightDirection() const
{
    if (direction == UCSwipeArea::Horizontal || direction == UCSwipeArea::Vertical) {
        return true;
    } else {
        QPointF movementVector(dampedScenePos.x() - previousDampedScenePos.x(), dampedScenePos.y() - previousDampedScenePos.y());

        qreal scalarProjection = projectOntoDirectionVector(movementVector);

        return scalarProjection >= 0.;
    }
}

bool UCSwipeAreaPrivate::movedFarEnoughAlongGestureAxis() const
{
    if (distanceThreshold <= 0.) {
        // distance threshold check is disabled
        return true;
    } else {
        QPointF totalMovement(dampedScenePos.x() - startScenePos.x(), dampedScenePos.y() - startScenePos.y());

        qreal scalarProjection = projectOntoDirectionVector(totalMovement);

        SA_TRACE(" movedFarEnoughAlongGestureAxis: scalarProjection=" << scalarProjection << ", distanceThreshold=" << distanceThreshold);

        if (direction == UCSwipeArea::Horizontal || direction == UCSwipeArea::Vertical) {
            return qAbs(scalarProjection) > distanceThreshold;
        } else {
            return scalarProjection > distanceThreshold;
        }
    }
}

bool UCSwipeAreaPrivate::isPastMaxDistance() const
{
    QPointF totalMovement(dampedScenePos.x() - startScenePos.x(), dampedScenePos.y() - startScenePos.y());

    qreal squaredDistance = totalMovement.x() * totalMovement.x() + totalMovement.y() * totalMovement.y();
    return squaredDistance > maxDistance * maxDistance;
}

void UCSwipeArea::giveUpIfDisabledOrInvisible()
{
    if (!isEnabled() || !isVisible()) {
        Q_D(UCSwipeArea);
        if (d->status == UCSwipeAreaPrivate::Undecided) {
            TouchRegistry::instance()->removeCandidateOwnerForTouch(d->touchId, this);
            // We still wanna know when it ends for keeping the composition time window up-to-date
            TouchRegistry::instance()->addTouchWatcher(d->touchId, this);
        }

        if (d->status != UCSwipeAreaPrivate::WaitingForTouch) {
            SA_TRACE("Resetting status because got disabled or made invisible");
            d->setStatus(UCSwipeAreaPrivate::WaitingForTouch);
        }
    }
}

void UCSwipeArea::rejectGesture()
{
    Q_D(UCSwipeArea);
    if (d->status == UCSwipeAreaPrivate::Undecided) {
        SA_TRACE("Rejecting gesture because it's taking too long to drag beyond the threshold.");

        TouchRegistry::instance()->removeCandidateOwnerForTouch(d->touchId, this);
        // We still wanna know when it ends for keeping the composition time window up-to-date
        TouchRegistry::instance()->addTouchWatcher(d->touchId, this);

        d->setStatus(UCSwipeAreaPrivate::WaitingForTouch);
    }
}

void UCSwipeAreaPrivate::setStatus(Status newStatus)
{
    if (newStatus == status)
        return;

    Status oldStatus = status;

    if (oldStatus == Undecided) {
        recognitionTimer->stop();
    }

    Q_Q(UCSwipeArea);
    const bool wasDragging = q->dragging();
    const bool wasPressed = q->pressed();

    status = newStatus;
    for (int i = 0; i < statusChangeListeners.size(); i++) {
        statusChangeListeners[i]->swipeStatusChanged(oldStatus, status);
    }

    SA_TRACE(statusToString(oldStatus) << " -> " << statusToString(newStatus));

    if (newStatus == Undecided) {
        recognitionTimer->start();
    }

    const bool isDragging = q->dragging();
    const bool isPressed = q->pressed();

    if (isDragging != wasDragging)
        Q_EMIT q->draggingChanged(isDragging);

    if (isPressed != wasPressed)
        Q_EMIT q->pressedChanged(isPressed);
}

void UCSwipeAreaPrivate::updatePosition(const QPointF &point)
{
    bool xChanged = publicScenePos.x() != point.x();
    bool yChanged = publicScenePos.y() != point.y();

    // Public position should not get updated while the gesture is still being recognized
    // (ie, Undecided status).
    Q_ASSERT(status == WaitingForTouch || status == Recognized);

    if (status == Recognized && !recognitionIsDisabled()) {
        // When the gesture finally gets recognized, the finger will likely be
        // reasonably far from the edge. If we made the contentX immediately
        // follow the finger position it would be visually unpleasant as it
        // would appear right next to the user's finger out of nowhere (ie,
        // it would jump). Instead, we make contentX go towards the user's
        // finger in several steps. ie., in an animated way.
        QPointF delta = point - publicScenePos;
        // the trick is not to go all the way (1.0) as it would cause a sudden jump
        publicScenePos.rx() += 0.4 * delta.x();
        publicScenePos.ry() += 0.4 * delta.y();
    } else {
        // no smoothing when initializing or if gesture recognition was immediate as there will
        // be no jump.
        publicScenePos = point;
    }

    if (xChanged || yChanged) {
        Q_Q(UCSwipeArea);
        Q_EMIT q->touchPositionChanged(q->touchPosition());

        // handle distance change
        QPointF totalMovement = publicScenePos - startScenePos;
        sceneDistance = projectOntoDirectionVector(totalMovement);

        Q_EMIT q->distanceChanged(sceneDistance);
    }
}

bool UCSwipeAreaPrivate::isWithinTouchCompositionWindow()
{
    return compositionTime > 0 && !activeTouches.isEmpty()
        && timeSource->msecsSinceReference() <= activeTouches.mostRecentStartTime() + (qint64)compositionTime;
}

void UCSwipeArea::itemChange(ItemChange change, const ItemChangeData &value)
{
    if (change == QQuickItem::ItemSceneChange) {
        if (value.window != nullptr) {
            value.window->installEventFilter(TouchRegistry::instance());

            // FIXME: Handle window->screen() changes (ie window changing screens)
            Q_D(UCSwipeArea);
            qreal pixelsPerInch = value.window->screen()->physicalDotsPerInch();
            if (pixelsPerInch < 0) {
                // FIXME: dpi can be negative lp#1525293
                // It can return garbage when run in a XVFB server (Virtual Framebuffer 'fake' X server)
                pixelsPerInch = 72;
            }
            d->setPixelsPerMm(pixelsPerInch / 25.4);
        }
    }
    if (change == ItemVisibleHasChanged) {
        giveUpIfDisabledOrInvisible();
    }
}

void UCSwipeAreaPrivate::setPixelsPerMm(qreal pixelsPerMm)
{
    dampedScenePos.setMaxDelta(1. * pixelsPerMm);
    setDistanceThreshold(4. * pixelsPerMm);
    maxDistance = 10. * pixelsPerMm;
}

//**************************  ActiveTouchesInfo **************************

ActiveTouchesInfo::ActiveTouchesInfo(const SharedTimeSource &timeSource)
    : m_timeSource(timeSource)
{
}

void ActiveTouchesInfo::update(QTouchEvent *event)
{
    if (!(event->touchPointStates() & (Qt::TouchPointPressed | Qt::TouchPointReleased))) {
        // nothing to update
        TI_TRACE("Nothing to update");
        return;
    }

    const QList<QTouchEvent::TouchPoint> &touchPoints = event->touchPoints();
    for (int i = 0; i < touchPoints.count(); ++i) {
        const QTouchEvent::TouchPoint &touchPoint = touchPoints.at(i);
        if (touchPoint.state() == Qt::TouchPointPressed) {
            addTouchPoint(touchPoint.id());
        } else if (touchPoint.state() == Qt::TouchPointReleased) {
            removeTouchPoint(touchPoint.id());
        }
    }
}

QString ActiveTouchesInfo::toString()
{
    QString string = QStringLiteral("(");

    {
        QTextStream stream(&string);
        m_touchInfoPool.forEach([&](Pool<ActiveTouchInfo>::Iterator &touchInfo) {
            stream << "(id=" << touchInfo->id << ",startTime=" << touchInfo->startTime << ")";
            return true;
        });
    }

    string.append(QStringLiteral(")"));

    return string;
}

void ActiveTouchesInfo::addTouchPoint(int touchId)
{
    ActiveTouchInfo &activeTouchInfo = m_touchInfoPool.getEmptySlot();
    activeTouchInfo.id = touchId;
    activeTouchInfo.startTime = m_timeSource->msecsSinceReference();

    TI_TRACE(qPrintable(toString()));
}

qint64 ActiveTouchesInfo::touchStartTime(int touchId)
{
    qint64 result = -1;

    m_touchInfoPool.forEach([&](Pool<ActiveTouchInfo>::Iterator &touchInfo) {
        if (touchId == touchInfo->id) {
            result = touchInfo->startTime;
            return false;
        } else {
            return true;
        }
    });

    Q_ASSERT(result != -1);
    return result;
}

void ActiveTouchesInfo::removeTouchPoint(int touchId)
{
    m_touchInfoPool.forEach([&](Pool<ActiveTouchInfo>::Iterator &touchInfo) {
        if (touchId == touchInfo->id) {
            m_touchInfoPool.freeSlot(touchInfo);
            return false;
        } else {
            return true;
        }
    });

    TI_TRACE(qPrintable(toString()));
}

qint64 ActiveTouchesInfo::mostRecentStartTime()
{
    Q_ASSERT(!m_touchInfoPool.isEmpty());

    qint64 highestStartTime = -1;

    m_touchInfoPool.forEach([&](Pool<ActiveTouchInfo>::Iterator &activeTouchInfo) {
        if (activeTouchInfo->startTime > highestStartTime) {
            highestStartTime = activeTouchInfo->startTime;
        }
        return true;
    });

    return highestStartTime;
}

void UCSwipeAreaPrivate::updateSceneDirectionVector()
{
    QPointF localOrigin(0., 0.);
    QPointF localDirection;
    switch (direction) {
    case UCSwipeArea::Upwards:
        localDirection.rx() = 0.;
        localDirection.ry() = -1.;
        break;
    case UCSwipeArea::Downwards:
    case UCSwipeArea::Vertical:
        localDirection.rx() = 0.;
        localDirection.ry() = 1;
        break;
    case UCSwipeArea::Leftwards:
        localDirection.rx() = -1.;
        localDirection.ry() = 0.;
        break;
    default: // UCSwipeArea::Rightwards || Direction.Horizontal
        localDirection.rx() = 1.;
        localDirection.ry() = 0.;
        break;
    }
    Q_Q(UCSwipeArea);
    QPointF sceneOrigin = q->mapToScene(localOrigin);
    QPointF sceneDirection = q->mapToScene(localDirection);
    sceneDirectionVector = sceneDirection - sceneOrigin;
}

qreal UCSwipeAreaPrivate::projectOntoDirectionVector(const QPointF &sceneVector) const
{
    // same as dot product as sceneDirectionVector is a unit vector
    return sceneVector.x() * sceneDirectionVector.x() + sceneVector.y() * sceneDirectionVector.y();
}

UCSwipeAreaPrivate::UCSwipeAreaPrivate()
    : QQuickItemPrivate()
    , timeSource(new RealTimeSource)
    , activeTouches(timeSource)
    , recognitionTimer(nullptr)
    , distanceThreshold(0)
    , distanceThresholdSquared(0.)
    , maxDistance(0.)
    , sceneDistance(0.)
    , touchId(-1)
    , maxTime(400)
    , compositionTime(60)
    , status(WaitingForTouch)
    , direction(UCSwipeArea::Rightwards)
    , immediateRecognition(false)
    , grabGesture(true)
{
}

void UCSwipeAreaPrivate::init()
{
    Q_Q(UCSwipeArea);
    setRecognitionTimer(new Timer(q));
    recognitionTimer->setInterval(maxTime);
    recognitionTimer->setSingleShot(true);

    QObject::connect(q, &QQuickItem::enabledChanged, q, &UCSwipeArea::giveUpIfDisabledOrInvisible);
}

void UCSwipeAreaPrivate::addStatusChangeListener(UCSwipeAreaStatusListener *listener)
{
    if (!statusChangeListeners.contains(listener)) {
        statusChangeListeners.append(listener);
    }
}

void UCSwipeAreaPrivate::removeStatusChangeListener(UCSwipeAreaStatusListener *listener)
{
    statusChangeListeners.removeAll(listener);
}
