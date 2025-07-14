/*
 *   SPDX-FileCopyrightText: 2025 Florian RICHER <florian.richer@protonmail.com>
 *
 *   SPDX-License-Identifier: GPL-2.0-or-later
 */

#pragma once

#include <QDir>
#include <QObject>
#include <qtmetamacros.h>

class WaydroidApplication : public QObject, public std::enable_shared_from_this<WaydroidApplication>
{
    Q_OBJECT
    Q_PROPERTY(QString name READ name CONSTANT)
    Q_PROPERTY(QString packageName READ packageName CONSTANT)

public:
    typedef std::shared_ptr<WaydroidApplication> Ptr;

    WaydroidApplication(QObject *parent = nullptr);

    static WaydroidApplication::Ptr fromWaydroidLog(QObject *parent, QTextStream &inFile);

    QString name() const;
    QString packageName() const;

private:
    QString m_name;
    QString m_packageName;
};
