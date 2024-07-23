// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-FileCopyrightText: 2020 The Qt Company Ltd.
// SPDX-License-Identifier: GPL-2.0-or-later

// based on Flickable, but heavily simplified

#include "swipearea.h"

#include <QMouseEvent>
#include <QObject>
#include <QQmlComponent>
#include <QQmlEngine>
#include <QTabletEvent>
#include <QTouchEvent>

// how many pixels to move before it starts being registered as a swipe
const int SWIPE_REGISTER_THRESHOLD = 10;

SwipeArea::SwipeArea(QQuickItem *parent)
    : QQuickItem{parent}
{
    setAcceptTouchEvents(true);
    setAcceptedMouseButtons(Qt::LeftButton);
    setFiltersChildMouseEvents(true);
}

SwipeArea::Mode SwipeArea::mode() const
{
    return m_mode;
}

void SwipeArea::setMode(Mode mode)
{
    m_mode = mode;
    Q_EMIT modeChanged();
}

bool SwipeArea::interactive() const
{
    return m_interactive;
}

void SwipeArea::setInteractive(bool interactive)
{
    m_interactive = interactive;
    Q_EMIT interactiveChanged();
}

bool SwipeArea::moving() const
{
    return m_moving;
}

bool SwipeArea::pressed() const
{
    return m_pressed;
}

void SwipeArea::setSkipSwipeThreshold(bool value)
{
    m_skipSwipeThreshold = value;
}

bool SwipeArea::childMouseEventFilter(QQuickItem *item, QEvent *event)
{
    if (!isVisible() || !isEnabled() || !m_interactive) {
        resetSwipe();
        return QQuickItem::childMouseEventFilter(item, event);
    }

    if (event->type() == QEvent::UngrabMouse) {
        auto spe = static_cast<QSinglePointEvent *>(event);
        const QObject *grabber = spe->exclusiveGrabber(spe->points().first());
        if (grabber != this) {
            resetSwipe(); // A child has been ungrabbed
        }
    } else if (event->isPointerEvent()) {
        return filterPointerEvent(item, static_cast<QPointerEvent *>(event));
    }

    return QQuickItem::childMouseEventFilter(item, event);
}

// take exclusive grab from children
bool SwipeArea::filterPointerEvent(QQuickItem *receiver, QPointerEvent *event)
{
    // only filter mouse, touch or tablet events
    if (!dynamic_cast<QMouseEvent *>(event) && !dynamic_cast<QTabletEvent *>(event) && !dynamic_cast<QTouchEvent *>(event)) {
        return false;
    }

    const auto &firstPoint = event->points().first();

    if (event->pointCount() == 1 && event->exclusiveGrabber(firstPoint) == this) {
        // We have an exclusive grab (since we're e.g dragging), but at the same time, we have
        // a child with a passive grab (which is why this filter is being called). And because
        // of that, we end up getting the same pointer events twice; First in our own event
        // handlers (because of the grab), then once more in here, since we filter the child.
        // To avoid processing the event twice (e.g avoid calling handleReleaseEvent once more
        // from below), we mark the event as filtered, and simply return.
        event->setAccepted(true);
        return true;
    }

    QPointF localPos = mapFromScene(firstPoint.scenePosition());
    bool receiverDisabled = receiver && !receiver->isEnabled();
    bool receiverKeepsGrab = receiver && (receiver->keepMouseGrab() || receiver->keepTouchGrab());

    qDebug() << receiverDisabled << receiverKeepsGrab << receiver;

    // Check if there is a nested flickable, and cancel events if it still is needs to flick
    QQuickItem *item = receiver;
    while (item->parentItem() && item->parentItem() != this) {
        auto metaObject = item->metaObject();
        bool isFlickable = metaObject->inherits(getFlickableMetaObject());

        if (isFlickable) {
            // HACK: detect if the flickable can move
            QVariant qInteractive = item->property("interactive");
            QVariant qDragging = item->property("dragging");
            if (qInteractive.isValid() && qDragging.isValid()) {
                bool interactive = qInteractive.toBool();
                bool dragging = qDragging.toBool();
                qDebug() << "dragging" << dragging;

                if (interactive && dragging) {
                    receiverKeepsGrab = true;
                    break;
                }
            }
        }

        item = item->parentItem();
    }

    if ((m_stealMouse || contains(localPos)) && (!receiver || !receiverKeepsGrab || receiverDisabled)) {
        // clone the event, and set the first point's local position
        // HACK: we can't change QPointerEvent's points since it's const, so we have to pass localPos into the handlers
        QPointerEvent *localizedEvent = event->clone();
        localizedEvent->setAccepted(false);

        switch (firstPoint.state()) {
        case QEventPoint::State::Updated:
            handleMoveEvent(localizedEvent, localPos);
            break;
        case QEventPoint::State::Pressed:
            handlePressEvent(localizedEvent, localPos);
            break;
        case QEventPoint::State::Released:
            handleReleaseEvent(localizedEvent, localPos);
            break;
        case QEventPoint::State::Stationary:
        case QEventPoint::State::Unknown:
            break;
        }

        if ((receiver && m_stealMouse && !receiverKeepsGrab && receiver != this) || receiverDisabled) {
            event->setExclusiveGrabber(firstPoint, this);
        }

        bool filtered = m_stealMouse || receiverDisabled;
        if (filtered) {
            event->setAccepted(true);
        }

        return filtered;
    }

    if (firstPoint.state() == QEventPoint::State::Released || (receiverKeepsGrab && !receiverDisabled)) {
        // mouse released, or another item has claimed the grab
        resetSwipe();
    }

    return false;
}

void SwipeArea::mouseMoveEvent(QMouseEvent *event)
{
    if (m_interactive) {
        handleMoveEvent(event, event->points().first().position());
        event->accept();
    } else {
        QQuickItem::mouseMoveEvent(event);
    }
}

void SwipeArea::mousePressEvent(QMouseEvent *event)
{
    if (m_interactive) {
        handlePressEvent(event, event->points().first().position());
        event->accept();
    } else {
        QQuickItem::mousePressEvent(event);
    }
}

void SwipeArea::mouseReleaseEvent(QMouseEvent *event)
{
    if (m_interactive) {
        handleReleaseEvent(event, event->points().first().position());
        event->accept();
    } else {
        QQuickItem::mouseReleaseEvent(event);
    }
}

void SwipeArea::mouseUngrabEvent()
{
    resetSwipe();
}

void SwipeArea::touchEvent(QTouchEvent *event)
{
    if (event->type() == QEvent::TouchCancel) {
        if (m_interactive) {
            resetSwipe();
        } else {
            QQuickItem::touchEvent(event);
        }
        return;
    }

    bool unhandled = true;
    const auto &firstPoint = event->points().first();

    switch (firstPoint.state()) {
    case QEventPoint::State::Pressed:
        if (m_interactive) {
            handlePressEvent(event, firstPoint.position());
            event->accept();
            unhandled = false;
        }
        break;
    case QEventPoint::State::Updated:
        if (m_interactive) {
            handleMoveEvent(event, firstPoint.position());
            event->accept();
            unhandled = false;
        }
        break;
    case QEventPoint::State::Released:
        if (m_interactive) {
            handleReleaseEvent(event, firstPoint.position());
            event->accept();
            unhandled = false;
        }
        break;
    case QEventPoint::State::Stationary:
    case QEventPoint::State::Unknown:
        break;
    }

    if (unhandled) {
        QQuickItem::touchEvent(event);
    }
}

void SwipeArea::touchUngrabEvent()
{
    resetSwipe();
}

void SwipeArea::wheelEvent(QWheelEvent *event)
{
    if (!m_interactive) {
        QQuickItem::wheelEvent(event);
        return;
    }

    event->setAccepted(false);

    switch (event->phase()) {
    case Qt::ScrollBegin:
        if (!m_touchpadScrolling) {
            event->accept();

            m_touchpadScrolling = true;
            m_totalScrollDelta = QPointF{0, 0};
            Q_EMIT touchpadScrollStarted(event->points().first().position());
        }
        break;
    case Qt::ScrollEnd:
        if (m_touchpadScrolling) {
            m_touchpadScrolling = false;
            m_totalScrollDelta = QPointF{0, 0};
            Q_EMIT touchpadScrollEnded();
        }
        break;
    default:
        break;
    }

    // HACK: if it isn't the touchpad, we never get the isBeginEvent() and isEndEvent() events
    if (!m_touchpadScrolling) {
        return;
    }

    for (auto &point : event->points()) {
        event->addPassiveGrabber(point, this);
    }

    auto pixelDelta = event->pixelDelta();
    m_totalScrollDelta = QPointF{m_totalScrollDelta + pixelDelta};
    Q_EMIT touchpadScrollMove(m_totalScrollDelta.x(), m_totalScrollDelta.y(), pixelDelta.x(), pixelDelta.y());

    event->accept();
}

void SwipeArea::setMoving(bool moving)
{
    m_moving = moving;
    Q_EMIT movingChanged();
}

void SwipeArea::setPressed(bool pressed)
{
    m_pressed = pressed;
    Q_EMIT pressedChanged();
}

void SwipeArea::resetSwipe()
{
    m_skipSwipeThreshold = false;
    m_stealMouse = false;
    if (m_pressed) {
        setPressed(false);
    }
    if (m_moving) {
        setMoving(false);
    }
}

void SwipeArea::handlePressEvent(QPointerEvent *event, QPointF point)
{
    Q_UNUSED(event)

    // ignore more touch events
    if (m_pressed) {
        return;
    }

    setPressed(true);
    m_stealMouse = false;
    m_pressPos = point;
    m_lastPos = m_pressPos;
}

void SwipeArea::handleReleaseEvent(QPointerEvent *event, QPointF point)
{
    Q_UNUSED(event)
    Q_UNUSED(point)

    // if we are in a swipe
    if (m_moving) {
        Q_EMIT swipeEnded();
    }

    resetSwipe();
}

void SwipeArea::handleMoveEvent(QPointerEvent *event, QPointF point)
{
    Q_UNUSED(event)

    if (!m_stealMouse) {
        if (!m_skipSwipeThreshold) {
            // if we haven't reached the swipe registering threshold yet, don't start the swipe
            if (m_mode == Mode::VerticalOnly && qAbs(point.y() - m_pressPos.y()) < SWIPE_REGISTER_THRESHOLD) {
                return;
            } else if (m_mode == Mode::HorizontalOnly && qAbs(point.x() - m_pressPos.x()) < SWIPE_REGISTER_THRESHOLD) {
                return;
            } else if (m_mode == Mode::BothAxis && qAbs(point.manhattanLength() - m_pressPos.manhattanLength()) < SWIPE_REGISTER_THRESHOLD) {
                return;
            }
        }
        m_skipSwipeThreshold = false;

        // we now start the swipe, stealing it from children

        m_startPos = point;
        m_lastPos = point;
        m_stealMouse = true;
        setMoving(true);
        Q_EMIT swipeStarted(m_startPos, m_pressPos);
    }

    const QVector2D totalDelta = QVector2D(point - m_startPos);
    const QVector2D delta = QVector2D(point - m_lastPos);
    m_lastPos = point;

    // ensure it's called AFTER swipeStarted()
    Q_EMIT swipeMove(totalDelta.x(), totalDelta.y(), delta.x(), delta.y());
}

const QMetaObject *SwipeArea::getFlickableMetaObject()
{
    if (!m_internalFlickable) {
        // HACK: To avoid relying on Qt Quick private API to get Flickable's QMetaObject,
        //       we dynamically create one internally.
        QQmlEngine *engine = qmlEngine(this);
        if (!engine) {
            return nullptr;
        }

        QQmlComponent component{engine};
        component.setData("import QtQuick; Flickable {}", QUrl{});
        m_internalFlickable = qobject_cast<QQuickItem *>(component.create());
    }

    return m_internalFlickable->metaObject();
}
