// SPDX-FileCopyrightText: 2022-2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "screenrotationutil.h"

#include <fcntl.h>
#include <unistd.h>

#include <kscreen/configmonitor.h>
#include <kscreen/getconfigoperation.h>
#include <kscreen/output.h>
#include <kscreen/setconfigoperation.h>

#include <QDebug>
#include <QOrientationSensor>
#include <QTimer>

ScreenRotationUtil::ScreenRotationUtil(QObject *parent)
    : QObject{parent}
    , m_config{nullptr}
    , m_sensor{new QOrientationSensor(this)}
{
    connect(m_sensor, &QOrientationSensor::activeChanged, this, &ScreenRotationUtil::availableChanged);

    connect(new KScreen::GetConfigOperation(), &KScreen::GetConfigOperation::finished, this, [this](auto *op) {
        m_config = qobject_cast<KScreen::GetConfigOperation *>(op)->config();

        // update all screens with event connect
        for (KScreen::OutputPtr output : m_config->outputs()) {
            connect(output.data(), &KScreen::Output::autoRotatePolicyChanged, this, &ScreenRotationUtil::autoScreenRotationEnabledChanged);
        }

        // listen to all new screens and connect
        connect(m_config.data(), &KScreen::Config::outputAdded, this, [this](const auto &output) {
            Q_EMIT autoScreenRotationEnabledChanged();
            connect(output.data(), &KScreen::Output::autoRotatePolicyChanged, this, &ScreenRotationUtil::autoScreenRotationEnabledChanged);
        });

        // trigger update
        Q_EMIT autoScreenRotationEnabledChanged();
    });
}

bool ScreenRotationUtil::autoScreenRotationEnabled()
{
    if (!m_config) {
        return false;
    }
    const auto outputs = m_config->outputs();

    for (KScreen::OutputPtr output : outputs) {
        if (output->autoRotatePolicy() == KScreen::Output::AutoRotatePolicy::Never) {
            return false;
        }
    }

    return true;
}

void ScreenRotationUtil::setAutoScreenRotationEnabled(bool value)
{
    // Don't execute immediately, in case the screen rotation
    // deletes the caller mid-function call, causing a crash.
    QTimer::singleShot(0, this, [this, value]() {
        actuallySetAutoScreenRotationEnabled(value);
    });
}

bool ScreenRotationUtil::isAvailable()
{
    return m_sensor->connectToBackend();
}

void ScreenRotationUtil::actuallySetAutoScreenRotationEnabled(bool value)
{
    if (!m_config) {
        return;
    }

    KScreen::Output::AutoRotatePolicy policy = value ? KScreen::Output::AutoRotatePolicy::Always : KScreen::Output::AutoRotatePolicy::Never;

    const auto outputs = m_config->outputs();
    for (KScreen::OutputPtr output : outputs) {
        if (output->autoRotatePolicy() != policy) {
            output->setAutoRotatePolicy(policy);
        }
    }

    auto setop = new KScreen::SetConfigOperation(m_config, this);
    setop->exec();

    Q_EMIT autoScreenRotationEnabledChanged();
}
