/*
 * SPDX-FileCopyrightText: 2022 by Devin Lin <devin@kde.org>
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

#include "powermenuutil.h"

#include <kworkspace.h>

PowerMenuUtil::PowerMenuUtil(QObject *parent)
    : QObject{parent}
{
}

void PowerMenuUtil::openShutdownScreen()
{
    KWorkSpace::requestShutDown(KWorkSpace::ShutdownConfirmYes);
}
