// SPDX-FileCopyrightText: 2023 by Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include <QDBusServiceWatcher>
#include <QObject>

#include <kscreen/config.h>

#include "brightnesscontrolinterface.h"

class PrepareUtil : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int scaling READ scaling WRITE setScaling NOTIFY scalingChanged);
    Q_PROPERTY(QStringList scalingOptions READ scalingOptions CONSTANT);
    Q_PROPERTY(int brightness READ brightness WRITE setBrightness NOTIFY brightnessChanged);
    Q_PROPERTY(int maxBrightness READ maxBrightness NOTIFY maxBrightnessChanged)
    Q_PROPERTY(bool brightnessAvailable READ brightnessAvailable NOTIFY brightnessAvailableChanged)

public:
    PrepareUtil(QObject *parent = nullptr);

    int scaling() const;
    void setScaling(int scaling);

    QStringList scalingOptions();

    int brightness() const;
    void setBrightness(int brightness);

    int maxBrightness() const;

    bool brightnessAvailable() const;

Q_SIGNALS:
    void scalingChanged();
    void brightnessChanged();
    void maxBrightnessChanged();
    void brightnessAvailableChanged();

private Q_SLOTS:
    void fetchBrightness();
    void fetchMaxBrightness();

private:
    int m_scaling;
    int m_brightness;
    int m_maxBrightness;

    KScreen::ConfigPtr m_config;
    org::kde::Solid::PowerManagement::Actions::BrightnessControl *m_brightnessInterface;
    QDBusServiceWatcher *m_brightnessInterfaceWatcher;
};
