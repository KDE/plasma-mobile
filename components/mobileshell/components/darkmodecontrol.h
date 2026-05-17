/*
 *  SPDX-FileCopyrightText: 2023 by Devin Lin <devin@kde.org>
 *  SPDX-FileCopyrightText: 2026 Florian Richer <florian.richer@protonmail.com>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

#pragma once

#include <QObject>
#include <qqmlintegration.h>

#include "colorssettings.h"

class DarkModeControl : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON
    Q_PROPERTY(bool darkMode READ darkMode WRITE setDarkMode NOTIFY darkModeChanged)

public:
    explicit DarkModeControl(QObject *parent = nullptr);

    [[nodiscard]] bool darkMode() const;
    void setDarkMode(const bool darkMode);
    
Q_SIGNALS:
    void darkModeChanged();

private:
    ColorsSettings *m_colorsSettings;
    bool m_darkMode;
};
