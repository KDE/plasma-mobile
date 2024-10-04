// SPDX-FileCopyrightText: 2022-2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include <QObject>
#include <QOrientationSensor>

#include <kscreen/config.h>

class ScreenRotationUtil : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool autoScreenRotationEnabled READ autoScreenRotationEnabled WRITE setAutoScreenRotationEnabled NOTIFY autoScreenRotationEnabledChanged);
    Q_PROPERTY(bool available READ isAvailable NOTIFY availableChanged);

public:
    ScreenRotationUtil(QObject *parent = nullptr);

    bool autoScreenRotationEnabled();
    void setAutoScreenRotationEnabled(bool value);

    bool isAvailable();

Q_SIGNALS:
    void autoScreenRotationEnabledChanged();
    void availableChanged();

private:
    void actuallySetAutoScreenRotationEnabled(bool value);

    KScreen::ConfigPtr m_config;
    QOrientationSensor *m_sensor;

    bool m_available;
};
