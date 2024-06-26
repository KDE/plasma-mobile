// SPDX-FileCopyrightText: 2024 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

const panel = new Panel("org.kde.plasma.mobile.panel");
panel.location = "top";
panel.addWidget("org.kde.plasma.notifications");
panel.height = 1.25 * gridUnit; // HACK: supposed to be gridUnit + smallSpacing, but it doesn't seem to give the correct number

const bottomPanel = new Panel("org.kde.plasma.mobile.taskpanel")
bottomPanel.location = "bottom";
bottomPanel.height = 2 * gridUnit;
