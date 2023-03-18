/**
 * SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

#include "kcm.h"

#include <KPluginFactory>

K_PLUGIN_CLASS_WITH_JSON(KCMMobileShell, "kcm_mobileshell.json")

KCMMobileShell::KCMMobileShell(QObject *parent, const KPluginMetaData &data, const QVariantList &args)
    : KQuickManagedConfigModule(parent, data, args)
{
    setButtons({});
}

#include "kcm.moc"
