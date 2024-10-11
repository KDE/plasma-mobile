// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include <QQuickItem>
#include <QTimer>
#include <Qt>

/**
 * @short A component that is similar to MouseArea but allows for a
 * simpler tracking of dragging movements after pressing and holding.
 *
 * @author Devin Lin <devin@kde.org>
 */
class DelegateTouchArea : public QQuickItem
{
    Q_OBJECT

    Q_PROPERTY(bool pressed READ pressed NOTIFY pressedChanged FINAL)
    Q_PROPERTY(bool hovered READ hovered NOTIFY hoveredChanged FINAL)
    Q_PROPERTY(Qt::CursorShape cursorShape READ cursorShape WRITE setCursorShape RESET unsetCursor NOTIFY cursorShapeChanged FINAL)
    Q_PROPERTY(QPointF pressPosition READ pressPosition NOTIFY pressPositionChanged FINAL)

    QML_NAMED_ELEMENT(DelegateTouchArea)

public:
    DelegateTouchArea(QQuickItem *parent = nullptr);

    bool pressed() const;
    bool hovered() const;
    Qt::CursorShape cursorShape() const;
    void setCursorShape(Qt::CursorShape cursorShape);
    void unsetCursor();
    QPointF pressPosition() const;

Q_SIGNALS:
    void clicked();
    void rightMousePress();
    void pressAndHold();
    void pressAndHoldReleased();
    void pressedChanged(bool pressed);
    void hoveredChanged(bool hovered);
    void cursorShapeChanged();
    void pressPositionChanged();

protected:
    void mousePressEvent(QMouseEvent *event) override;
    void mouseReleaseEvent(QMouseEvent *event) override;
    void mouseMoveEvent(QMouseEvent *event) override;
    void mouseUngrabEvent() override;
    void touchEvent(QTouchEvent *event) override;
    void touchUngrabEvent() override;
    void hoverEnterEvent(QHoverEvent *event) override;
    void hoverLeaveEvent(QHoverEvent *event) override;

private Q_SLOTS:
    void startPressAndHold();
    void startPress();

private:
    void setPressed(bool pressed);
    void setHovered(bool hovered);
    void setDragging(bool dragging);

    void handlePressEvent(QPointerEvent *event, QPointF point);
    void handleReleaseEvent(QPointerEvent *event, bool click);
    void handleMoveEvent(QPointerEvent *event, QPointF point);

    bool m_pressed{false};
    bool m_hovered{false};
    bool m_pressAndHeld{false};
    Qt::CursorShape m_cursorShape{Qt::ArrowCursor};
    QPointF m_mouseDownPosition{};

    QTimer *m_pressAndHoldTimer{nullptr};
    QTimer *m_pressTimer{nullptr};
};

QML_DECLARE_TYPE(DelegateTouchArea)
