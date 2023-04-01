// SPDX-FileCopyrightText: 2023 by Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include <QObject>
#include <QProcess>

class WiFiUtil : public QObject
{
    Q_OBJECT

public:
    WiFiUtil(QObject *parent = nullptr);
};
