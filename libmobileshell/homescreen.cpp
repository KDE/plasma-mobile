// SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

#include "homescreen.h"

#include <QFileInfo>

#include <KPackage/PackageLoader>

using namespace MobileShell;

HomeScreen::HomeScreen(QObject *parent, const KPluginMetaData &data, const QVariantList &args)
    : Plasma::Containment{parent, data, args}
{
}
