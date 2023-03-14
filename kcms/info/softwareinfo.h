/*
    SPDX-FileCopyrightText: 2019 Jonah Brüchert <jbb@kaidan.im>

    SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
*/

#include <QObject>

#ifndef SOFTWAREINFO_H
#define SOFTWAREINFO_H

class SoftwareInfo : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString kernelRelease READ kernelRelease CONSTANT)
    Q_PROPERTY(QString frameworksVersion READ frameworksVersion CONSTANT)
    Q_PROPERTY(QString qtVersion READ qtVersion CONSTANT)
    Q_PROPERTY(QString plasmaVersion READ plasmaVersion CONSTANT)
    Q_PROPERTY(QString osType READ osType CONSTANT)

public:
    SoftwareInfo(QObject *parent = nullptr);
    QString kernelRelease() const;
    QString frameworksVersion() const;
    QString qtVersion() const;
    QString plasmaVersion() const;
    QString osType() const;
};

#endif // SOFTWAREINFO_H
