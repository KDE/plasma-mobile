// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include <QList>
#include <QObject>
#include <qqmlregistration.h>

#include "hapticinterface.h"
#include "vibrationevent.h"

#include <QCoroDBusPendingReply>

class VibrationManager : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

public:
    VibrationManager(QObject *parent = nullptr);

    Q_INVOKABLE QCoro::Task<void> vibrate(int durationMs);

private:
    OrgSigxcpuFeedbackHapticInterface *m_interface{nullptr};
};
