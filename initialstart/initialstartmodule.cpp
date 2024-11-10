// SPDX-FileCopyrightText: 2024 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

#include "initialstartmodule.h"

InitialStartModule::InitialStartModule(QObject *parent)
    : QObject{parent}
{
}

QString InitialStartModule::name() const
{
    return m_name;
}

void InitialStartModule::setName(QString name)
{
    if (m_name == name) {
        return;
    }
    m_name = name;
    Q_EMIT nameChanged();
}

bool InitialStartModule::available() const
{
    return m_available;
}

void InitialStartModule::setAvailable(bool available)
{
    if (m_available == available) {
        return;
    }
    m_available = available;
    Q_EMIT availableChanged();
}

QQuickItem *InitialStartModule::contentItem()
{
    return m_contentItem;
}

void InitialStartModule::setContentItem(QQuickItem *contentItem)
{
    if (m_contentItem == contentItem) {
        return;
    }
    m_contentItem = contentItem;
    Q_EMIT contentItemChanged();
}

QQmlListProperty<QObject> InitialStartModule::children()
{
    return QQmlListProperty<QObject>(this, &m_children);
}
