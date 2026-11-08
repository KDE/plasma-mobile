// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include <QList>
#include <QObject>
#include <QString>
#include <QStringList>
#include <QVariantMap>
#include <qqmlregistration.h>

#include "dbuspropertiesinterface.h"
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

    /**
     * The current feedbackd profile ("full", "quiet" or "silent"), empty if not known yet.
     */
    Q_PROPERTY(QString profile READ profile NOTIFY profileChanged)

public:
    VibrationManager(QObject *parent = nullptr);

    QString profile();

    QCoro::Task<void> vibrateTask(int durationMs);
    Q_INVOKABLE QCoro::QmlTask vibrate(int durationMs);

Q_SIGNALS:
    void profileChanged();

private:
    void onFeedbackPropertiesChanged(const QString &interface, const QVariantMap &changed, const QStringList &invalidated);

    void loadDeviceTuning();
    void connectToFeedbackd();
    QCoro::Task<void> fetchProfile();
    void setProfile(const QString &profile);

    OrgSigxcpuFeedbackHapticInterface *m_interface{nullptr};
    OrgFreedesktopDBusPropertiesInterface *m_propertiesInterface{nullptr};

    bool m_connectedToFeedbackd{false};
    bool m_profileFetched{false};
    QString m_profile;

    double m_amplitude{1.0};
};
