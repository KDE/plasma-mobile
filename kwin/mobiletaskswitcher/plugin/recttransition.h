// SPDX-FileCopyrightText: 2026 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include <QPointF>
#include <QQuickItem>
#include <QRectF>
#include <qqmlintegration.h>

/**
 * Moves an item towards a rectangle on the screen.
 *
 * Used to animate tasks from where they were before a layout change, and to grow a task into its window.
 */
class RectTransition : public QQuickTransform
{
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(qreal progress READ progress WRITE setProgress NOTIFY progressChanged)
    // the top of the content that is moved to the target, in item coordinates
    Q_PROPERTY(qreal anchorY READ anchorY WRITE setAnchorY NOTIFY anchorYChanged)

public:
    explicit RectTransition(QObject *parent = nullptr);

    qreal progress() const;
    void setProgress(qreal progress);
    qreal anchorY() const;
    void setAnchorY(qreal anchorY);

    // Current position of rectangle
    Q_INVOKABLE QRectF contentRect(QQuickItem *item) const;

    // Set target destination
    Q_INVOKABLE void setTarget(QQuickItem *item, const QRectF &target);

    void applyTo(QMatrix4x4 *matrix) const override;

Q_SIGNALS:
    void progressChanged();
    void anchorYChanged();

private:
    qreal m_progress = 0;
    qreal m_anchorY = 0;
    bool m_measuring = false;
    qreal m_targetScale = 1;
    QPointF m_targetOffset;
};
