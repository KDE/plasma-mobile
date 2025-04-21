/*
 *   SPDX-FileCopyrightText: 2025 Micah Stanley <stanleymicah@proton.me>
 *
 *   SPDX-License-Identifier: GPL-2.0-or-later
 */

#pragma once

#include <QObject>
#include <QOrientationSensor>

#include <kscreen/config.h>
#include <qqmlregistration.h>
#include <qtmetamacros.h>

class RotationUtil : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    Q_PROPERTY(bool showRotationButton READ showRotationButton NOTIFY rotationChanged)
    Q_PROPERTY(Rotation deviceRotation READ deviceRotation NOTIFY rotationChanged)
    Q_PROPERTY(Rotation currentRotation READ currentRotation NOTIFY rotationChanged)

public:
    RotationUtil(QObject *parent = nullptr);

    enum Rotation {
        Portrait = 0,
        LandscapeLeft,
        UpsideDown,
        LandscapeRight
    };
    Q_ENUM(Rotation)

    bool showRotationButton() const;
    Rotation deviceRotation() const;
    Rotation currentRotation() const;

    Q_INVOKABLE void rotateToSuggestedRotation();

Q_SIGNALS:
    void rotationChanged();

private Q_SLOTS:
    void updateShowRotationButton();

private:
    bool m_showRotationButton{false};
    KScreen::Output::Rotation m_rotateTo;
    Rotation m_deviceRotation;
    Rotation m_currentRotation;

    KScreen::ConfigPtr m_config{nullptr};
    QOrientationSensor *m_sensor{nullptr};
};
