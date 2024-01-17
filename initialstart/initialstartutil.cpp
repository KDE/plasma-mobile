// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "initialstartutil.h"

InitialStartUtil::InitialStartUtil(QObject *parent)
    : QObject{parent}
{
}

QString InitialStartUtil::distroName() const
{
    return m_osrelease.name();
}