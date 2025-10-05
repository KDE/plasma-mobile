/*
 *   SPDX-FileCopyrightText: 2025 Micah Stanley <stanleymicah@proton.me>
 *
 *   SPDX-License-Identifier: GPL-2.0-or-later
 */

#include "rotationutil.h"

#include <QDBusConnection>
#include <QDBusPendingReply>
#include <QDebug>
#include <QGuiApplication>

#include <kscreen/configmonitor.h>
#include <kscreen/getconfigoperation.h>
#include <kscreen/output.h>
#include <kscreen/setconfigoperation.h>
#include <qtmetamacros.h>

KScreen::Output::Rotation mapReadingOrientation(QOrientationReading::Orientation orientation)
{
    switch (orientation) {
        case QOrientationReading::Orientation::TopUp:
            return KScreen::Output::Rotation::None;
        case QOrientationReading::Orientation::TopDown:
            return KScreen::Output::Rotation::Inverted;
        case QOrientationReading::Orientation::LeftUp:
            return KScreen::Output::Rotation::Left;
        case QOrientationReading::Orientation::RightUp:
            return KScreen::Output::Rotation::Right;
        case QOrientationReading::Orientation::FaceUp:
        case QOrientationReading::Orientation::FaceDown:
        case QOrientationReading::Orientation::Undefined:
            return KScreen::Output::Rotation::None;
    }
    return KScreen::Output::Rotation::None;
}

RotationUtil::Rotation mapRotation(KScreen::Output::Rotation rotation)
{
    switch (rotation) {
        case KScreen::Output::Rotation::Left:
            return RotationUtil::Rotation::LandscapeLeft;
        case KScreen::Output::Rotation::Inverted:
            return RotationUtil::Rotation::UpsideDown;
        case KScreen::Output::Rotation::Right:
            return RotationUtil::Rotation::LandscapeRight;
        default:
            return RotationUtil::Rotation::Portrait;
    }
}

RotationUtil::RotationUtil(QObject *parent)
: QObject{parent}
, m_sensor{new QOrientationSensor(this)}
{
    connect(new KScreen::GetConfigOperation(), &KScreen::GetConfigOperation::finished, this, [this](auto *op) {
        m_config = qobject_cast<KScreen::GetConfigOperation *>(op)->config();
        if (!m_config) {
            return;
        }

        KScreen::ConfigMonitor::instance()->addConfig(m_config);

        // update all screens with event connect
        for (KScreen::OutputPtr output : m_config->outputs()) {
            connect(output.data(), &KScreen::Output::autoRotatePolicyChanged, this, &RotationUtil::updateShowRotationButton);
        }

        // listen to all new screens and connect
        connect(m_config.data(), &KScreen::Config::outputAdded, this, [this](const auto &output) {
            connect(output.data(), &KScreen::Output::autoRotatePolicyChanged, this, &RotationUtil::updateShowRotationButton);
        });
    });

    connect(m_sensor, &QOrientationSensor::readingChanged, this, &RotationUtil::updateShowRotationButton);
    m_sensor->start();
}

void RotationUtil::rotateToSuggestedRotation()
{
    if (!m_config || !m_showRotationButton) {
        return;
    }

    const auto outputs = m_config->outputs();
    if (outputs.empty()) {
        return;
    }

    // HACK: Assume the output we care about is the first device
    for (KScreen::OutputPtr output : outputs) {
        // apparently it's possible to get nullptr outputs?
        if (!output) {
            continue;
        }

        output->setRotation(m_rotateTo);
    }

    auto setop = new KScreen::SetConfigOperation(m_config, this);
    setop->exec();

    updateShowRotationButton();
}

bool RotationUtil::showRotationButton() const
{
    return m_showRotationButton;
}

RotationUtil::Rotation RotationUtil::deviceRotation() const
{
    return m_deviceRotation;
}

RotationUtil::Rotation RotationUtil::currentRotation() const
{
    return m_currentRotation;
}

void RotationUtil::updateShowRotationButton()
{
    if (!m_config) {
        return;
    }

    QOrientationReading *reading = m_sensor->reading();
    if (!reading) {
        return;
    }

    m_rotateTo = mapReadingOrientation(reading->orientation());
    m_deviceRotation = mapRotation(m_rotateTo);

    const auto outputs = m_config->outputs();

    if (outputs.empty()) {
        m_showRotationButton = false;
        Q_EMIT rotationChanged();
        return;
    }

    // HACK: Assume the output we care about is the first device
    for (KScreen::OutputPtr output : outputs) {
        if (!output) {
            // apparently it's possible to get nullptr outputs?
            continue;
        }
        if (output->autoRotatePolicy() != KScreen::Output::AutoRotatePolicy::Never) {
            // only check displays that have autorotate on
            continue;
        }
        m_currentRotation = mapRotation(output->rotation());
        m_showRotationButton = output->rotation() != m_rotateTo;
        Q_EMIT rotationChanged();
        return;
    }

    m_showRotationButton = false;
    Q_EMIT rotationChanged();
}
