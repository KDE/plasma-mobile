// SPDX-FileCopyrightText: 2023 Devin Lin <espidev@gmail.com>
// SPDX-License-Identifier: LGPL-2.0-or-later

#pragma once

#include <QMouseEvent>
#include <QPointF>
#include <QPointerEvent>
#include <QQmlListProperty>
#include <QQuickItem>
#include <QTouchEvent>

/**
 * @short A component that provides access to swipes over its children, similar to Flickable.
 * However, it does not do any of the positioning Flickable does, and so it
 * can be used to build custom components with specialized swiping needs (ex. panels)
 *
 * TODO: New fingers that come in should steal from the old finger
 *
 * @author Devin Lin <devin@kde.org>
 */
class SwipeArea : public QQuickItem
{
    Q_OBJECT
    QML_ELEMENT
    Q_PROPERTY(SwipeArea::Mode mode READ mode WRITE setMode NOTIFY modeChanged)
    Q_PROPERTY(bool interactive READ interactive WRITE setInteractive NOTIFY interactiveChanged)
    Q_PROPERTY(bool moving READ moving NOTIFY movingChanged)
    Q_PROPERTY(bool pressed READ pressed NOTIFY pressedChanged)

public:
    SwipeArea(QQuickItem *parent = nullptr);

    enum Mode { BothAxis = 0, VerticalOnly, HorizontalOnly };
    Q_ENUM(Mode)

    Mode mode() const;
    void setMode(Mode mode);

    bool interactive() const;
    void setInteractive(bool interactive);

    bool moving() const;
    bool pressed() const;

    Q_INVOKABLE void setSkipSwipeThreshold(bool value);

Q_SIGNALS:
    void modeChanged();
    void interactiveChanged();
    void movingChanged();
    void pressedChanged();

    void swipeEnded();
    void swipeStarted(QPointF currentPoint, QPointF startPoint); // we let the user move a couple of pixels for swipe detection

    // deltaX, deltaY - amount moved since last swipeMove()
    // totalDeltaX, totalDeltaY - amount move since startedSwipe()
    void swipeMove(qreal totalDeltaX, qreal totalDeltaY, qreal deltaX, qreal deltaY);

    void touchpadScrollStarted(QPointF point);
    void touchpadScrollEnded();
    void touchpadScrollMove(qreal totalDeltaX, qreal totalDeltaY, qreal deltaX, qreal deltaY);

protected:
    bool childMouseEventFilter(QQuickItem *item, QEvent *event) override;
    void mouseMoveEvent(QMouseEvent *event) override;
    void mousePressEvent(QMouseEvent *event) override;
    void mouseReleaseEvent(QMouseEvent *event) override;
    void mouseUngrabEvent() override;
    void touchEvent(QTouchEvent *event) override;
    void touchUngrabEvent() override;
    void wheelEvent(QWheelEvent *event) override;

private:
    void setMoving(bool moving);
    void setPressed(bool pressed);

    bool filterPointerEvent(QQuickItem *receiver, QPointerEvent *event);

    void handlePressEvent(QPointerEvent *event, QPointF point);
    void handleReleaseEvent(QPointerEvent *event, QPointF point);
    void handleMoveEvent(QPointerEvent *event, QPointF point);

    void resetSwipe();

    const QMetaObject *getFlickableMetaObject();

    Mode m_mode = Mode::BothAxis;
    bool m_interactive = true;
    bool m_pressed = false;
    bool m_touchpadScrolling = false;

    // whether we have started a flick
    bool m_moving = false;

    // whether on this current flick, we want to steal the mouse/touch event from children
    bool m_stealMouse = false;

    // the point where the user pressed down on at the start of the interaction
    QPointF m_pressPos;

    // the point where the swipe actually started being registered (can be some distance from the pressed position)
    QPointF m_startPos;

    // the previous point where interaction was at
    QPointF m_lastPos;

    // whether to skip trying to measure the swipe threshold
    bool m_skipSwipeThreshold;

    // the total amount of distance scrolled
    QPointF m_totalScrollDelta;

    QQuickItem *m_internalFlickable = nullptr;
};

QML_DECLARE_TYPE(SwipeArea)
