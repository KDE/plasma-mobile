// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "vibrationmanager.h"

VibrationManager::VibrationManager(QObject *parent)
    : QObject{parent}
{
    const auto objectPath = QStringLiteral("/com/lomiri/hfd");
    m_interface = new com::lomiri::hfd::Vibrator("com.lomiri.hfd", objectPath, QDBusConnection::systemBus(), this);
}

void VibrationManager::vibrate(int durationMs)
{
    m_interface->vibrate(durationMs);
}
