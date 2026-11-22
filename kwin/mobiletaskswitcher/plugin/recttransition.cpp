// SPDX-FileCopyrightText: 2026 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "recttransition.h"

#include <QMatrix4x4>

RectTransition::RectTransition(QObject *parent)
    : QQuickTransform{parent}
{
}

qreal RectTransition::progress() const
{
    return m_progress;
}

void RectTransition::setProgress(qreal progress)
{
    if (m_progress != progress) {
        m_progress = progress;
        update();
        Q_EMIT progressChanged();
    }
}

qreal RectTransition::anchorY() const
{
    return m_anchorY;
}

void RectTransition::setAnchorY(qreal anchorY)
{
    if (m_anchorY != anchorY) {
        m_anchorY = anchorY;
        update();
        Q_EMIT anchorYChanged();
    }
}

QRectF RectTransition::contentRect(QQuickItem *item) const
{
    if (!item || item->width() <= 0) {
        return {};
    }
    const QPointF topLeft = item->mapToScene({0, m_anchorY});
    const QPointF topRight = item->mapToScene({item->width(), m_anchorY});
    const qreal width = topRight.x() - topLeft.x();
    return {topLeft, QSizeF{width, width * (item->height() - m_anchorY) / item->width()}};
}

void RectTransition::setTarget(QQuickItem *item, const QRectF &target)
{
    // measure without this transition
    m_measuring = true;
    update();
    const QRectF current = contentRect(item);
    m_measuring = false;

    m_targetScale = 1;
    m_targetOffset = {};
    update();
    if (current.width() <= 0 || target.width() <= 0) {
        return;
    }
    // the scale of the item's coordinates on the screen
    const qreal itemScale = current.width() / item->width();
    m_targetScale = target.width() / current.width();
    m_targetOffset = (target.topLeft() - current.topLeft()) / itemScale;
    update();
}

void RectTransition::applyTo(QMatrix4x4 *matrix) const
{
    if (m_progress == 0 || m_measuring) {
        return;
    }
    // scale around the top left of the content, which moves towards the target
    const qreal scale = 1 + (m_targetScale - 1) * m_progress;
    matrix->translate(m_progress * m_targetOffset.x(), m_anchorY + m_progress * m_targetOffset.y());
    matrix->scale(scale, scale);
    matrix->translate(0, -m_anchorY);
}
