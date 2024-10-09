/*
    SPDX-FileCopyrightText: 2019 Jonah Brüchert <jbb@kaidan.im>

    SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
*/

#include <QObject>

#ifndef HARDWAREINFO_H
#define HARDWAREINFO_H

class HardwareInfo : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString processors READ processors CONSTANT)
    Q_PROPERTY(int processorCount READ processorCount CONSTANT)
    Q_PROPERTY(QString memory READ memory CONSTANT)
    Q_PROPERTY(QString gpu READ gpu CONSTANT)

public:
    HardwareInfo(QObject *parent = nullptr);

    QString processors() const;
    int processorCount() const;
    QString memory() const;
    QString gpu() const;
};

#endif // HARDWAREINFO_H
