// SPDX-FileCopyrightText: 2025 Micah Stanley <stanleymicah@proton.me>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include <QQuickItem>

class QSGNode;

class MaskLayer : public QQuickItem
{
    Q_OBJECT
    QML_ELEMENT

public:
    explicit MaskLayer(QQuickItem *parent = nullptr);
    ~MaskLayer() override;

    Q_INVOKABLE void addItem(QQuickItem* item);
    Q_INVOKABLE void removeItem(QQuickItem* item);

protected:
    QSGNode *updatePaintNode(QSGNode *oldNode, UpdatePaintNodeData *updatePaintNodeData) override;

private slots:
    void scheduleUpdate();

private:
    void disconnectItemSignals(QQuickItem* item);

    QVector<QPointer<QQuickItem>> m_sourceItems;
    QHash<QQuickItem*, QVector<QMetaObject::Connection>> m_connections;
};
