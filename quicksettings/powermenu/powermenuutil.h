/*
 * SPDX-FileCopyrightText: 2022 by Devin Lin <devin@kde.org>
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

#pragma once

#include <QObject>

class PowerMenuUtil : public QObject
{
    Q_OBJECT

public:
    PowerMenuUtil(QObject *parent = nullptr);

    Q_INVOKABLE void openShutdownScreen();
};
