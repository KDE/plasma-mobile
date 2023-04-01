// SPDX-FileCopyrightText: 2023 by Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "wifiutil.h"

#include <QDebug>
#include <QRegularExpression>
#include <QTimeZone>

#include <KConfigGroup>
#include <KSharedConfig>

WiFiUtil::WiFiUtil(QObject *parent)
    : QObject{parent}
{
}
