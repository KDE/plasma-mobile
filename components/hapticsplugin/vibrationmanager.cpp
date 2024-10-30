// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "vibrationmanager.h"

VibrationManager::VibrationManager(QObject *parent)
    : QObject{parent}
{
}

void VibrationManager::vibrate(int durationMs)
{
    // Only create interface when needed.
    if (!m_interface) {
        const auto objectPath = QStringLiteral("/com/lomiri/hfd");
        m_interface = new com::lomiri::hfd::Vibrator("com.lomiri.hfd", objectPath, QDBusConnection::systemBus(), this);
    }
    m_interface->vibrate(durationMs);
}
