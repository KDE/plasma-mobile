/*
 *   SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>
 *   SPDX-FileCopyrightText: 2018 Bhushan Shah <bshah@kde.org>
 *
 *   SPDX-License-Identifier: GPL-2.0-or-later
 */

#include "phonepanel.h"

PhonePanel::PhonePanel(QObject *parent, const KPluginMetaData &data, const QVariantList &args)
    : Plasma::Containment(parent, data, args)
{
}

PhonePanel::~PhonePanel() = default;

K_PLUGIN_CLASS(PhonePanel)

#include "phonepanel.moc"
