/*
 *   SPDX-FileCopyrightText: 2025 Micah Stanley <stanleymicah@proton.me>
 *
 *   SPDX-License-Identifier: GPL-2.0-or-later
 */

#pragma once

#include <QObject>

#include <kscreen/config.h>
#include <qqmlregistration.h>
#include <qtmetamacros.h>

class SensorProxy;

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
    void retrieveKScreen();

    bool m_showRotationButton{false};
    KScreen::Output::Rotation m_rotateTo{KScreen::Output::Rotation::None};
    Rotation m_deviceRotation{Rotation::Portrait};
    Rotation m_currentRotation{Rotation::Portrait};

    KScreen::ConfigPtr m_config{nullptr};
    SensorProxy *m_sensorProxy{nullptr};
};
