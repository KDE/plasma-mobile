/*
 *   SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>
 *   SPDX-FileCopyrightText: 2018 Bhushan Shah <bshah@kde.org>
 *
 *   SPDX-License-Identifier: GPL-2.0-or-later
 */

#include "phonepanel.h"

PhonePanel::PhonePanel(QObject *parent, const QVariantList &args)
    : Plasma::Containment(parent, args)
{
}

PhonePanel::~PhonePanel() = default;
