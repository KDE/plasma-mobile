// SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

#pragma once

#include "homescreen.h"
#include "qqml.h"

#include <QAbstractListModel>
#include <QQmlListProperty>

#include "mobileshell_export.h"

namespace MobileShell
{

class MOBILESHELL_EXPORT HomeScreenModel : public QObject
{
    Q_OBJECT

public:
    HomeScreenModel(QObject *parent = nullptr);
};

} // namespace MobileShell
