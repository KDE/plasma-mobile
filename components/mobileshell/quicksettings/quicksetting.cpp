/*
 *   SPDX-FileCopyrightText: 2021 Aleix Pol Gonzalez <aleixpol@kde.org>
 *
 *   SPDX-License-Identifier: LGPL-2.0-or-later
 */

#include "quicksetting.h"

QuickSetting::QuickSetting(QObject *parent)
    : QObject(parent)
{
}

void QuickSetting::setEnabled(bool enabled)
{
    if (m_enabled == enabled)
        return;

    m_enabled = enabled;
    Q_EMIT enabledChanged(enabled);
}

void QuickSetting::setAvailable(bool available)
{
    if (m_available == available)
        return;

    m_available = available;
    Q_EMIT availableChanged(available);
}

void QuickSetting::setSettingsCommand(const QString &settingsCommand)
{
    if (m_settingsCommand == settingsCommand)
        return;

    m_settingsCommand = settingsCommand;
    Q_EMIT settingsCommandChanged(settingsCommand);
}

void QuickSetting::setIconName(const QString &iconName)
{
    if (m_iconName == iconName)
        return;

    m_iconName = iconName;
    Q_EMIT iconNameChanged(iconName);
}

void QuickSetting::setText(const QString &text)
{
    if (m_text == text)
        return;

    m_text = text;
    Q_EMIT textChanged(text);
}

void QuickSetting::setStatus(const QString &status)
{
    if (m_status == status)
        return;

    m_status = status;
    Q_EMIT statusChanged(status);
}

QQmlListProperty<QObject> QuickSetting::children()
{
    return QQmlListProperty<QObject>(this, &m_children);
}
