// SPDX-FileCopyrightText: 2024 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include <QDBusServiceWatcher>
#include <QObject>
#include <qqmlregistration.h>

#include "brightnesscontrolinterface.h"

/**
 * Utility class that provides useful functions related to screen brightness.
 *
 * @author Devin Lin <devin@kde.org>
 **/
class ScreenBrightnessUtil : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int brightness READ brightness WRITE setBrightness NOTIFY brightnessChanged);
    Q_PROPERTY(int maxBrightness READ maxBrightness NOTIFY maxBrightnessChanged)
    Q_PROPERTY(bool brightnessAvailable READ brightnessAvailable NOTIFY brightnessAvailableChanged)
    QML_ELEMENT

public:
    ScreenBrightnessUtil(QObject *parent = nullptr);

    int brightness() const;
    void setBrightness(int brightness);

    int maxBrightness() const;

    bool brightnessAvailable() const;

Q_SIGNALS:
    void brightnessChanged();
    void maxBrightnessChanged();
    void brightnessAvailableChanged();

private Q_SLOTS:
    void fetchBrightness();
    void fetchMaxBrightness();

private:
    int m_brightness{0};
    int m_maxBrightness{0};

    org::kde::Solid::PowerManagement::Actions::BrightnessControl *m_brightnessInterface;
    QDBusServiceWatcher *m_brightnessInterfaceWatcher;
};
