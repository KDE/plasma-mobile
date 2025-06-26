/*
 *   SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>
 *   SPDX-FileCopyrightText: 2018 Bhushan Shah <bshah@kde.org>
 *
 *   SPDX-License-Identifier: GPL-2.0-or-later
 */

#include "phonepanel.h"

K_PLUGIN_CLASS_WITH_JSON(PhonePanel, "metadata.json")

PhonePanel::PhonePanel(QObject *parent, const KPluginMetaData &data, const QVariantList &args)
    : Plasma::Containment(parent, data, args)
{
}

PhonePanel::~PhonePanel() = default;

#include "phonepanel.moc"
