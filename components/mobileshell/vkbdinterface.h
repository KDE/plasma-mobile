/*
 *   SPDX-FileCopyrightText: 2021 Aleix Pol <apol@kde.org>
 *
 *   SPDX-License-Identifier: GPL-2.0-or-later
 */

#pragma once

#include <QDBusConnection>
#include <QObject>
#include <QString>

#include <virtualkeyboardinterface.h>

class KwinVirtualKeyboardInterface : public OrgKdeKwinVirtualKeyboardInterface
{
    Q_OBJECT
    Q_PROPERTY(bool active READ active WRITE setActive NOTIFY activeChanged)
    Q_PROPERTY(bool enabled READ enabled WRITE setEnabled NOTIFY enabledChanged)
    Q_PROPERTY(bool visible READ visible NOTIFY visibleChanged)
public:
    KwinVirtualKeyboardInterface();
};
