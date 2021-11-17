/*
 *  SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

#include "swipearea.h"

SwipeArea::SwipeArea(QQuickItem *parent)
    : QQuickItem{parent}
    , m_enabled{true}
    , m_dragging{false}
    , m_deltaPosition{0.0, 0.0}
    , m_inTouchDrag{false}
    , m_inMouseDrag{false}
    , m_dragThreshold{5.0}
{
    setAcceptedMouseButtons(Qt::LeftButton);
    setAcceptTouchEvents(false); // rely on mouse events synthesized from touch
    setFiltersChildMouseEvents(true);
}

bool SwipeArea::enabled()
{
    return m_enabled;
}

void SwipeArea::setEnabled(bool enabled)
{
    if (enabled != m_enabled) {
        m_enabled = enabled;
        reset();
        Q_EMIT enabledChanged();
    }
}

bool SwipeArea::dragging()
{
    return m_dragging;
}

QPointF SwipeArea::deltaPosition()
{
    return m_deltaPosition;
}

void SwipeArea::reset()
{
    m_dragging = false;
    m_deltaPosition = QPointF{0.0, 0.0};
    Q_EMIT draggingChanged();
    Q_EMIT deltaPositionChanged();
    setKeepMouseGrab(false);
    m_inTouchDrag = false;
    m_inMouseDrag = false;
}

void SwipeArea::mousePressEvent(QMouseEvent *event)
{
    if (m_enabled && !m_inTouchDrag) {
        if (event->button() & Qt::LeftButton) {
            m_inMouseDrag = true;
            handlePressEvent(event->pos());
            setKeepMouseGrab(true);
        }
        event->accept();
    } else {
        QQuickItem::mousePressEvent(event);
    }
}

void SwipeArea::mouseReleaseEvent(QMouseEvent *event)
{
    if (m_enabled && !m_inTouchDrag) {
        if (event->button() & Qt::LeftButton) {
            m_inMouseDrag = false;
            handleReleaseEvent();
        }
        event->accept();
    } else {
        QQuickItem::mouseReleaseEvent(event);
    }
}

void SwipeArea::mouseMoveEvent(QMouseEvent *event)
{
    if (m_enabled && !m_inTouchDrag) {
        if (event->button() & Qt::LeftButton) {
            handleMoveEvent(event->pos());
        }
        event->accept();
    } else {
        QQuickItem::mouseMoveEvent(event);
    }
}

void SwipeArea::touchEvent(QTouchEvent *event)
{
    if (!m_enabled)
        return;
    if (m_inMouseDrag)
        return;

    const auto &firstTouchPoint = event->touchPoints().first();

    switch (firstTouchPoint.state()) {
    case Qt::TouchPointPressed:
        m_inTouchDrag = true;
        handlePressEvent(firstTouchPoint.pos());
        event->accept();
        break;
    case Qt::TouchPointReleased:
        m_inTouchDrag = false;
        handleReleaseEvent();
        event->accept();
        break;
    case Qt::TouchPointMoved:
        handleMoveEvent(firstTouchPoint.pos());
        break;
    case Qt::TouchPointStationary:
        break;
    }
}

bool SwipeArea::childMouseEventFilter(QQuickItem *item, QEvent *event)
{
    return false; // TODO
}

void SwipeArea::handlePressEvent(QPointF point)
{
    m_trueStartPosition = point;
}

void SwipeArea::handleReleaseEvent()
{
    reset();
}

void SwipeArea::handleMoveEvent(QPointF moveTo)
{
    if (m_dragging) {
        m_deltaPosition = moveTo - m_startPosition;
        Q_EMIT deltaPositionChanged();
    } else {
        auto delta = moveTo - m_trueStartPosition;
        if (delta.manhattanLength() >= m_dragThreshold) {
            m_startPosition = moveTo;
            m_dragging = true;
            Q_EMIT draggingChanged();
        }
    }
}
