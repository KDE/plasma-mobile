/*
 *   SPDX-FileCopyrightText: 2021 Aleix Pol <apol@kde.org>
 *
 *   SPDX-License-Identifier: GPL-2.0-or-later
 */

#include "kwinvirtualkeyboardinterface.h"

using namespace MobileShell;

KwinVirtualKeyboardInterface::KwinVirtualKeyboardInterface()
    : OrgKdeKwinVirtualKeyboardInterface(QStringLiteral("org.kde.KWin"), QStringLiteral("/VirtualKeyboard"), QDBusConnection::sessionBus())
{
}
