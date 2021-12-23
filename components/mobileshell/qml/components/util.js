/*
 *   SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
 *
 *   SPDX-License-Identifier: GPL-2.0-or-later
 */

function applyMinMaxRange(min, max, num) {
    return Math.min(max, Math.max(min, num));
}
