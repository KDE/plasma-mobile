// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include <kdedmodule.h>

class PlasmaMobileStartDaemon : public KDEDModule
{
    Q_OBJECT

public:
    PlasmaMobileStartDaemon(QObject *parent, const QList<QVariant> &);
};
