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

ScreenRotationUtil::ScreenRotationUtil(QObject *parent)
    : QObject{parent}
    , m_config{nullptr}
    , m_sensor{new QOrientationSensor(this)}
{
    connect(m_sensor, &QOrientationSensor::activeChanged, this, &ScreenRotationUtil::availableChanged);

    connect(new KScreen::GetConfigOperation(), &KScreen::GetConfigOperation::finished, this, [this](auto *op) {
        m_config = qobject_cast<KScreen::GetConfigOperation *>(op)->config();

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
        if (output->autoRotatePolicy() != KScreen::Output::AutoRotatePolicy::Always) {
            return false;
        }
    }

    return true;
}

void ScreenRotationUtil::setAutoScreenRotationEnabled(bool value)
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

    Q_EMIT autoScreenRotationEnabledChanged();
}

bool ScreenRotationUtil::isAvailable()
{
    return m_sensor->connectToBackend();
}
