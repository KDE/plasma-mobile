// SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

/**
 * Applies both the min and max functions to a value.
 */
function applyMinMaxRange(min, max, num) {
    return Math.min(max, Math.max(min, num));
}
