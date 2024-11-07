// SPDX-FileCopyrightText: 2024 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

#pragma once

#include "qqml.h"
#include <QAbstractListModel>
#include <QQmlListProperty>
#include <QQuickItem>

class InitialStartModule : public QObject
{
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(bool available READ available WRITE setAvailable NOTIFY availableChanged)
    Q_PROPERTY(QQuickItem *contentItem READ contentItem WRITE setContentItem REQUIRED NOTIFY contentItemChanged)
    Q_PROPERTY(QQmlListProperty<QObject> children READ children CONSTANT)
    Q_CLASSINFO("DefaultProperty", "children")

public:
    InitialStartModule(QObject *parent = nullptr);

    bool available() const;
    void setAvailable(bool available);

    QQuickItem *contentItem();
    void setContentItem(QQuickItem *contentItem);

    QQmlListProperty<QObject> children();

Q_SIGNALS:
    void availableChanged();
    void contentItemChanged();

private:
    bool m_available{true};
    QQuickItem *m_contentItem{nullptr};
    QList<QObject *> m_children;
};
