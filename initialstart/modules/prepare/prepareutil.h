// SPDX-FileCopyrightText: 2023 by Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include <QDBusServiceWatcher>
#include <QObject>

#include <kscreen/config.h>

#include "colorssettings.h"

class PrepareUtil : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int scaling READ scaling WRITE setScaling NOTIFY scalingChanged);
    Q_PROPERTY(QStringList scalingOptions READ scalingOptions CONSTANT);
    Q_PROPERTY(bool usingDarkTheme READ usingDarkTheme WRITE setUsingDarkTheme NOTIFY usingDarkThemeChanged)

public:
    PrepareUtil(QObject *parent = nullptr);

    int scaling() const;
    void setScaling(int scaling);

    QStringList scalingOptions();

    bool usingDarkTheme() const;
    void setUsingDarkTheme(bool usingDarkTheme);

Q_SIGNALS:
    void scalingChanged();
    void usingDarkThemeChanged();

private:
    void initKScreen(std::function<void()> callback);
    void setScalingInternal(int scaling);

    int m_scaling;
    bool m_usingDarkTheme;

    int m_output{0};

    ColorsSettings *m_colorsSettings;
    KScreen::ConfigPtr m_config;
};
