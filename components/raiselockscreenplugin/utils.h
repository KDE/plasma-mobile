// SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include <QLoggingCategory>

static const QLoggingCategory &LOGGING_CATEGORY()
{
    static const QLoggingCategory category("raiselockscreenplugin");
    return category;
}
