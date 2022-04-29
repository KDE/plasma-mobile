/*
 * SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

#pragma once

#include <QObject>

class Haptics : public QObject
{
    Q_OBJECT

public:
    static Haptics *self();

    Q_INVOKABLE void buttonVibrate();
};
