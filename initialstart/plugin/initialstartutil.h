// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include <KOSRelease>
#include <QObject>

class InitialStartUtil : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString distroName READ distroName CONSTANT);

public:
    InitialStartUtil(QObject *parent = nullptr);

    QString distroName() const;

private:
    KOSRelease m_osrelease;
};
