// SPDX-FileCopyrightText: 2016 The Qt Company Ltd.
// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "delegatetoucharea.h"

#include <QCursor>
#include <QGuiApplication>
#include <QStyleHints>

// Some code taken from MouseArea

DelegateTouchArea::DelegateTouchArea(QQuickItem *parent)
    : QQuickItem{parent}
    , m_pressAndHoldTimer{new QTimer{this}}
{
    m_pressAndHoldTimer->setInterval(600);
    m_pressAndHoldTimer->setSingleShot(true);
    connect(m_pressAndHoldTimer, &QTimer::timeout, this, &DelegateTouchArea::startPressAndHold);

    // Explcitly call setCursor on QQuickItem since
    // it internally keeps a boolean hasCursor that doesn't
    // get set to true unless you call setCursor
    setCursor(Qt::ArrowCursor);

    setAcceptHoverEvents(true);
    setAcceptTouchEvents(true);
    setFlags(QQuickItem::ItemIsFocusScope);
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

QPointF DelegateTouchArea::pressPosition()
{
    return m_mouseDownPosition;
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

void DelegateTouchArea::handlePressEvent(QPointerEvent *event, QPointF point)
{
    Q_UNUSED(event)
    // ignore multiple press events
    if (m_pressed) {
        return;
    }

    setPressed(true);
    forceActiveFocus(Qt::MouseFocusReason);

    m_mouseDownPosition = point;
    Q_EMIT pressPositionChanged();

    m_pressAndHoldTimer->start();
}

void DelegateTouchArea::handleReleaseEvent(QPointerEvent *event, bool click)
{
    // NOTE: event can be nullptr!
    Q_UNUSED(event)
    bool wasPressed = m_pressed;
    setPressed(false);

    if (!m_pressAndHeld && click && wasPressed) {
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
    Q_UNUSED(event)
    if (QPointF(point - m_mouseDownPosition).manhattanLength() >= QGuiApplication::styleHints()->startDragDistance()) {
        m_pressAndHoldTimer->stop();
        setPressed(false);
    }
}

void DelegateTouchArea::startPressAndHold()
{
    m_pressAndHeld = true;
    Q_EMIT pressAndHold();
}
