// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include <QObject>
#include <qqmlregistration.h>

#include "hfdinterface.h"

class VibrationManager : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

public:
    VibrationManager(QObject *parent = nullptr);

    Q_INVOKABLE void vibrate(int durationMs);

private:
    com::lomiri::hfd::Vibrator *m_interface{nullptr};
};