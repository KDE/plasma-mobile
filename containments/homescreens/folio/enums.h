// SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include <QObject>

class Enums : public QObject
{
    Q_OBJECT

public:
    enum Direction {
        Up,
        Down,
        Left,
        Right
    };
    Q_ENUM(Direction)
};
