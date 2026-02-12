// SPDX-FileCopyrightText: 2025 Micah Stanley <stanleymicah@proton.me>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include <QQuickItem>

class MaskLayer;

class MaskManager : public QQuickItem
{
    Q_OBJECT
    QML_ELEMENT
    Q_PROPERTY(QQuickItem* maskLayer READ maskLayer CONSTANT)

public:
    explicit MaskManager(QQuickItem *parent = nullptr);
    ~MaskManager() override;

    QQuickItem* maskLayer() const;

    Q_INVOKABLE void assignToMask(QQuickItem* item);

protected:
    void componentComplete() override;

private:
    MaskLayer* m_maskLayer;
};
