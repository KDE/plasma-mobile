/*
 *   SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>
 *
 *   SPDX-License-Identifier: GPL-2.0-or-later
 */

#include "taskpanel.h"

#include <QDBusConnection>
#include <QDBusPendingReply>
#include <QDebug>
#include <QGuiApplication>

#include <kscreen/configmonitor.h>
#include <kscreen/getconfigoperation.h>
#include <kscreen/output.h>
#include <kscreen/setconfigoperation.h>

// register type for Keyboards.KWinVirtualKeyboard.forceActivate();
Q_DECLARE_METATYPE(QDBusPendingReply<>)

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

TaskPanel::TaskPanel(QObject *parent, const KPluginMetaData &data, const QVariantList &args)
    : Plasma::Containment(parent, data, args)
    , m_sensor{new QOrientationSensor(this)}
{
    connect(new KScreen::GetConfigOperation(), &KScreen::GetConfigOperation::finished, this, [this](auto *op) {
        m_config = qobject_cast<KScreen::GetConfigOperation *>(op)->config();
        KScreen::ConfigMonitor::instance()->addConfig(m_config);

        // update all screens with event connect
        for (KScreen::OutputPtr output : m_config->outputs()) {
            connect(output.data(), &KScreen::Output::autoRotatePolicyChanged, this, &TaskPanel::updateShowRotationButton);
        }

        // listen to all new screens and connect
        connect(m_config.data(), &KScreen::Config::outputAdded, this, [this](const auto &output) {
            connect(output.data(), &KScreen::Output::autoRotatePolicyChanged, this, &TaskPanel::updateShowRotationButton);
        });
    });

    connect(m_sensor, &QOrientationSensor::readingChanged, this, &TaskPanel::updateShowRotationButton);
    m_sensor->start();
}

void TaskPanel::triggerTaskSwitcher() const
{
    QDBusMessage message = QDBusMessage::createMethodCall("org.kde.kglobalaccel", "/component/kwin", "org.kde.kglobalaccel.Component", "invokeShortcut");
    message.setArguments({QStringLiteral("Mobile Task Switcher")});

    // this does not block, so it won't necessarily be called before the method returns
    QDBusConnection::sessionBus().send(message);
}

void TaskPanel::rotateToSuggestedRotation()
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

bool TaskPanel::showRotationButton() const
{
    return m_showRotationButton;
}

void TaskPanel::updateShowRotationButton()
{
    if (!m_config) {
        return;
    }

    QOrientationReading *reading = m_sensor->reading();
    if (!reading) {
        return;
    }

    m_rotateTo = mapReadingOrientation(reading->orientation());

    const auto outputs = m_config->outputs();

    if (outputs.empty()) {
        m_showRotationButton = false;
        Q_EMIT showRotationButtonChanged();
        return;
    }

    // HACK: Assume the output we care about is the first device
    for (KScreen::OutputPtr output : outputs) {
        if (!output) {
            // apparently it's possible to get nullptr outputs?
            continue;
        }
        if (output->autoRotatePolicy() == KScreen::Output::AutoRotatePolicy::Always) {
            // only check displays that have autorotate on
            continue;
        }

        m_showRotationButton = output->rotation() != m_rotateTo;
        Q_EMIT showRotationButtonChanged();
        return;
    }

    m_showRotationButton = false;
    Q_EMIT showRotationButtonChanged();
}

K_PLUGIN_CLASS(TaskPanel)

#include "taskpanel.moc"
