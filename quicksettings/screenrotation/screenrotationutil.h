/*
 * SPDX-FileCopyrightText: 2022 by Devin Lin <devin@kde.org>
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

#pragma once

#include <QObject>

#include "kscreeninterface.h"

class ScreenRotationUtil : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool screenRotationEnabled READ screenRotation WRITE setScreenRotation NOTIFY screenRotationChanged);
    Q_PROPERTY(bool available READ isAvailable);

public:
    ScreenRotationUtil(QObject *parent = nullptr);

    bool screenRotation();
    void setScreenRotation(bool value);

    bool isAvailable();

Q_SIGNALS:
    void screenRotationChanged(bool value);

private:
    org::kde::KScreen *m_kscreenInterface;
};
