/*
 *  SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

#pragma once

#include <QObject>
#include <qqmlregistration.h>

class Direction : public QObject
{
    Q_OBJECT
    QML_ELEMENT

public:
    enum Type { None = 0, Up, Down, Left, Right };
    Q_ENUM(Type)
};
