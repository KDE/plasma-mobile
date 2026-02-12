// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include <QList>
#include <QObject>
#include <qqmlregistration.h>

#include "hapticinterface.h"
#include "vibrationevent.h"

#include <QCoroCore>
#include <QCoroDBusPendingReply>
#include <QCoroQml>
#include <QCoroQmlTask>

class VibrationManager : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

public:
    VibrationManager(QObject *parent = nullptr);

    QCoro::Task<void> vibrateTask(int durationMs);
    Q_INVOKABLE QCoro::QmlTask vibrate(int durationMs);

private:
    OrgSigxcpuFeedbackHapticInterface *m_interface{nullptr};
};
