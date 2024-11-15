// SPDX-FileCopyrightText: 2024 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

const panel = new Panel("org.kde.plasma.mobile.panel");
panel.location = "top";
panel.height = 1.25 * gridUnit; // HACK: supposed to be gridUnit + smallSpacing, but it doesn't seem to give the correct number
