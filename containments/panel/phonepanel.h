/*
 *   SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>
 *
 *   SPDX-License-Identifier: GPL-2.0-or-later
 */

#ifndef PHONEPANEL_H
#define PHONEPANEL_H

#include <Plasma/Containment>

class PhonePanel : public Plasma::Containment
{
    Q_OBJECT

public:
    PhonePanel(QObject *parent, const KPluginMetaData &data, const QVariantList &args);
    ~PhonePanel() override;
};

#endif
