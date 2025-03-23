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

class RotationUtil : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    Q_PROPERTY(bool showRotationButton READ showRotationButton NOTIFY rotationChanged)
    Q_PROPERTY(int deviceRotation READ deviceRotation NOTIFY rotationChanged)
    Q_PROPERTY(int currentRotation READ currentRotation NOTIFY rotationChanged)

public:
    RotationUtil(QObject *parent = nullptr);

    bool showRotationButton() const;
    int deviceRotation() const;
    int currentRotation() const;
    Q_INVOKABLE void rotateToSuggestedRotation();

Q_SIGNALS:
    void rotationChanged();

private Q_SLOTS:
    void updateShowRotationButton();

private:
    bool m_showRotationButton{false};
    KScreen::Output::Rotation m_rotateTo;
    KScreen::Output::Rotation m_currentRotate;

    KScreen::ConfigPtr m_config{nullptr};
    QOrientationSensor *m_sensor{nullptr};
};
