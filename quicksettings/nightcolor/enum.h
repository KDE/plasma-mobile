/*
SPDX-FileCopyrightText: 2021 Benjamin Port <benjamin.port@enioka.com>

SPDX-License-Identifier: GPL-2.0-or-later
*/

#pragma once

#include <qobjectdefs.h>

namespace ColorCorrect
{
Q_NAMESPACE
enum NightColorMode {
    /**
     * Color temperature is constant throughout the day.
     */
    Constant,
    /**
     * The color temperature is adjusted based on time of day.
     */
    DarkLight,
};

Q_ENUM_NS(NightColorMode)
}
