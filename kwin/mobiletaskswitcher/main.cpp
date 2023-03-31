// SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "mobiletaskswitchereffect.h"

namespace KWin
{

KWIN_EFFECT_FACTORY_SUPPORTED(MobileTaskSwitcherEffect, "mobiletaskswitcher.json", return MobileTaskSwitcherEffect::supported();)

} // namespace KWin

#include "main.moc"
