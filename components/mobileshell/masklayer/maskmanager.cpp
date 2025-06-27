// SPDX-FileCopyrightText: 2025 Micah Stanley <stanleymicah@proton.me>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "maskmanager.h"
#include "masklayer.h"

MaskManager::MaskManager(QQuickItem *parent)
: QQuickItem(parent),
m_maskLayer(new MaskLayer(this))
{
}

MaskManager::~MaskManager() = default;

void MaskManager::componentComplete() {
    QQuickItem::componentComplete();
    // ensure the mask layers fill the dimensions
    m_maskLayer->setX(0);
    m_maskLayer->setY(0);
    m_maskLayer->setWidth(width());
    m_maskLayer->setHeight(height());
    m_maskLayer->setZ(z());

    connect(this, &QQuickItem::widthChanged, this, [this]() {
        m_maskLayer->setWidth(width());
    });
    connect(this, &QQuickItem::heightChanged, this, [this]() {
        m_maskLayer->setHeight(height());
    });
}

QQuickItem* MaskManager::maskLayer() const {
    return m_maskLayer;
}

void MaskManager::assignToMask(QQuickItem* item) {
    if (!item) {
        qWarning() << "Cannot assign a null item to a mask.";
        return;
    }

    m_maskLayer->addItem(item);
}
