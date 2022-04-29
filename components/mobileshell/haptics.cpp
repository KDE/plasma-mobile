/*
 * SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

#include "haptics.h"

#include <QFeedbackHapticsEffect>

#include "mobileshellsettings.h"

Haptics *Haptics::self()
{
    static Haptics *singleton = new Haptics();
    return singleton;
}

void Haptics::buttonVibrate()
{
    if (MobileShellSettings::self()->vibrationsEnabled()) {
        QFeedbackHapticsEffect rumble;
        rumble.setIntensity(0.5);
        rumble.setDuration(100);
        rumble.start();
    }
}
