// SPDX-FileCopyrightText: 2016 The Qt Company Ltd.
// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "delegatetoucharea.h"

#include <QCursor>

// Some code taken from MouseArea

DelegateTouchArea::DelegateTouchArea(QQuickItem *parent)
    : QQuickItem{parent}
    , m_pressAndHoldTimer{new QTimer{this}}
{
    // TODO: currently hardcoded 2s press and hold interval
    m_pressAndHoldTimer->setInterval(600);
    m_pressAndHoldTimer->setSingleShot(true);
    connect(m_pressAndHoldTimer, &QTimer::timeout, this, &DelegateTouchArea::startPressAndHold);

    // Explcitly call setCursor on QQuickItem since
    // it internally keeps a boolean hasCursor that doesn't
    // get set to true unless you call setCursor
    setCursor(Qt::ArrowCursor);

    setAcceptHoverEvents(true);
    setAcceptTouchEvents(true);
    // setFiltersChildMouseEvents(true);
    setAcceptedMouseButtons(Qt::LeftButton | Qt::RightButton);
}

bool DelegateTouchArea::pressed()
{
    return m_pressed;
}

void DelegateTouchArea::setPressed(bool pressed)
{
    if (pressed != m_pressed) {
        m_pressed = pressed;
        Q_EMIT pressedChanged(pressed);
    }
}

bool DelegateTouchArea::hovered()
{
    return m_hovered;
}

void DelegateTouchArea::setHovered(bool hovered)
{
    if (hovered != m_hovered) {
        m_hovered = hovered;
        Q_EMIT hoveredChanged(hovered);
    }
}

bool DelegateTouchArea::dragging()
{
    return m_dragging;
}

void DelegateTouchArea::setDragging(bool dragging)
{
    if (dragging != m_dragging) {
        m_dragging = dragging;
        Q_EMIT draggingChanged(dragging);
    }
}

Qt::CursorShape DelegateTouchArea::cursorShape()
{
    return cursor().shape();
}

void DelegateTouchArea::setCursorShape(Qt::CursorShape cursorShape)
{
    if (cursor().shape() == cursorShape) {
        return;
    }

    setCursor(cursorShape);
    Q_EMIT cursorShapeChanged();
}

void DelegateTouchArea::unsetCursor()
{
    setCursorShape(Qt::ArrowCursor);
}

void DelegateTouchArea::mousePressEvent(QMouseEvent *event)
{
    if (event->button() & Qt::RightButton) {
        Q_EMIT rightMousePress();
    } else if (event->button() & Qt::LeftButton) {
        handlePressEvent(event, event->points().first().position());
        event->accept();
    } else {
        QQuickItem::mousePressEvent(event);
    }
}

void DelegateTouchArea::mouseMoveEvent(QMouseEvent *event)
{
    handleMoveEvent(event, event->points().first().position());
    event->accept();
}

void DelegateTouchArea::mouseReleaseEvent(QMouseEvent *event)
{
    if (event->button() & Qt::LeftButton) {
        handleReleaseEvent(event, true);
        event->accept();
    } else {
        QQuickItem::mouseReleaseEvent(event);
    }
}

void DelegateTouchArea::mouseUngrabEvent()
{
    if (m_pressed) {
        handleReleaseEvent(nullptr, false);
    }
    QQuickItem::mouseUngrabEvent();
}

void DelegateTouchArea::touchEvent(QTouchEvent *event)
{
    bool unhandled = true;
    const auto &firstPoint = event->points().first();

    switch (firstPoint.state()) {
    case QEventPoint::State::Pressed:
        handlePressEvent(event, firstPoint.position());
        event->accept();
        unhandled = false;
        break;
    case QEventPoint::State::Updated:
        handleMoveEvent(event, firstPoint.position());
        event->accept();
        unhandled = false;
        break;
    case QEventPoint::State::Released:
        handleReleaseEvent(event, true);
        event->accept();
        unhandled = false;
        break;
    case QEventPoint::State::Stationary:
    case QEventPoint::State::Unknown:
        break;
    }

    if (unhandled) {
        QQuickItem::touchEvent(event);
    }
}

void DelegateTouchArea::touchUngrabEvent()
{
    if (m_pressed) {
        handleReleaseEvent(nullptr, false);
    }
    QQuickItem::touchUngrabEvent();
}

void DelegateTouchArea::hoverEnterEvent(QHoverEvent *event)
{
    setHovered(true);

    // don't block hover events
    event->ignore();
}

void DelegateTouchArea::hoverLeaveEvent(QHoverEvent *event)
{
    setHovered(false);

    // don't block hover events
    event->ignore();
}

// bool DelegateTouchArea::childMouseEventFilter(QQuickItem *item, QEvent *event)
// {
//     if (!isVisible() || !isEnabled()) {
//         handleReleaseEvent(nullptr, false);
//         return QQuickItem::childMouseEventFilter(item, event);
//     }
//
//     if (event->isPointerEvent() && event->type() != QEvent::UngrabMouse) {
//         return filterPointerEvent(item, static_cast<QPointerEvent *>(event));
//     }
//
//     return QQuickItem::childMouseEventFilter(item, event);
// }
//
// // take exclusive grab from children
// bool DelegateTouchArea::filterPointerEvent(QQuickItem *receiver, QPointerEvent *event)
// {
//     // only filter mouse, touch or tablet events
//     if (!dynamic_cast<QMouseEvent *>(event) && !dynamic_cast<QTabletEvent *>(event) && !dynamic_cast<QTouchEvent *>(event)) {
//         return false;
//     }
//
//     const auto &firstPoint = event->points().first();
//
//     if (event->pointCount() == 1 && event->exclusiveGrabber(firstPoint) == this) {
//         // We have an exclusive grab (since we're e.g dragging), but at the same time, we have
//         // a child with a passive grab (which is why this filter is being called). And because
//         // of that, we end up getting the same pointer events twice; First in our own event
//         // handlers (because of the grab), then once more in here, since we filter the child.
//         // To avoid processing the event twice (e.g avoid calling handleReleaseEvent once more
//         // from below), we mark the event as filtered, and simply return.
//         event->setAccepted(true);
//         return true;
//     }
//
//     QPointF localPos = mapFromScene(firstPoint.scenePosition());
//     bool receiverDisabled = receiver && !receiver->isEnabled();
//     bool receiverKeepsGrab = receiver && (receiver->keepMouseGrab() || receiver->keepTouchGrab());
//
//     if ((m_pressAndHeld || contains(localPos)) && (!receiver || !receiverKeepsGrab || receiverDisabled)) {
//         // clone the event, and set the first point's local position
//         // HACK: we can't change QPointerEvent's points since it's const, so we have to pass localPos into the handlers
//         QPointerEvent *localizedEvent = event->clone();
//         localizedEvent->setAccepted(false);
//
//         switch (firstPoint.state()) {
//         case QEventPoint::State::Updated:
//             handleMoveEvent(localizedEvent, localPos);
//             break;
//         case QEventPoint::State::Pressed:
//             handlePressEvent(localizedEvent, localPos);
//             break;
//         case QEventPoint::State::Released:
//             handleReleaseEvent(localizedEvent, true);
//             break;
//         case QEventPoint::State::Stationary:
//         case QEventPoint::State::Unknown:
//             break;
//         }
//
//         if ((receiver && m_pressAndHeld && !receiverKeepsGrab && receiver != this) || receiverDisabled) {
//             event->setExclusiveGrabber(firstPoint, this);
//         }
//
//         bool filtered = m_pressAndHeld || receiverDisabled;
//         if (filtered) {
//             event->setAccepted(true);
//         }
//
//         return filtered;
//     }
//
//     if (firstPoint.state() == QEventPoint::State::Released || (receiverKeepsGrab && !receiverDisabled)) {
//         // mouse released, or another item has claimed the grab
//         handleReleaseEvent(nullptr, false);
//     }
//
//     return false;
// }

void DelegateTouchArea::handlePressEvent(QPointerEvent *event, QPointF point)
{
    // ignore multiple press events
    if (m_pressed) {
        return;
    }

    setPressed(true);
    m_pressAndHoldTimer->start();
}

void DelegateTouchArea::handleReleaseEvent(QPointerEvent *event, bool click)
{
    // NOTE: event can be nullptr!

    setPressed(false);
    setDragging(false);

    if (!m_pressAndHeld && click) {
        Q_EMIT clicked();
    }

    if (m_pressAndHeld) {
        Q_EMIT pressAndHoldReleased();
    }

    m_pressAndHoldTimer->stop();
    m_pressAndHeld = false;
}

void DelegateTouchArea::handleMoveEvent(QPointerEvent *event, QPointF point)
{
    if (m_pressAndHeld) {
        // TODO
    }
}

void DelegateTouchArea::startPressAndHold()
{
    m_pressAndHeld = true;
    Q_EMIT pressAndHold();
}
