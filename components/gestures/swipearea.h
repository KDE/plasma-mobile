/*
 *  SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

#pragma once

#include <QQuickItem>

class SwipeArea : public QQuickItem
{
    Q_OBJECT

    Q_PROPERTY(bool enabled READ enabled WRITE setEnabled NOTIFY enabledChanged)
    Q_PROPERTY(bool dragging READ dragging NOTIFY draggingChanged)
    Q_PROPERTY(QPointF deltaPosition READ deltaPosition NOTIFY deltaPositionChanged)

public:
    SwipeArea(QQuickItem *parent = nullptr);

    bool enabled();
    void setEnabled(bool enabled);
    bool dragging();
    QPointF deltaPosition();

    void reset();

protected:
    void mousePressEvent(QMouseEvent *event) override;
    void mouseReleaseEvent(QMouseEvent *event) override;
    void mouseMoveEvent(QMouseEvent *event) override;
    void touchEvent(QTouchEvent *event) override;
    bool childMouseEventFilter(QQuickItem *item, QEvent *event) override;

Q_SIGNALS:
    void enabledChanged();
    void draggingChanged();
    void deltaPositionChanged();

private:
    bool m_enabled;
    bool m_dragging;
    QPointF m_deltaPosition;

    bool m_inTouchDrag;
    bool m_inMouseDrag;

    qreal m_dragThreshold;
    QPointF m_startPosition; // start position where drag is calculated from (not including threshold)
    QPointF m_trueStartPosition; // start position from press event

    void handlePressEvent(QPointF point);
    void handleReleaseEvent();
    void handleMoveEvent(QPointF moveTo);
};
