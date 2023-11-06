// SPDX-FileCopyrightText: 2023 by Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include <QObject>
#include <QProcess>

#include <kscreen/config.h>

class PrepareUtil : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int scaling READ scaling WRITE setScaling NOTIFY scalingChanged);
    Q_PROPERTY(QStringList scalingOptions READ scalingOptions CONSTANT);

public:
    PrepareUtil(QObject *parent = nullptr);

    int scaling() const;
    void setScaling(int scaling);

    QStringList scalingOptions();

Q_SIGNALS:
    void scalingChanged();

private:
    int m_scaling;
    KScreen::ConfigPtr m_config;
};
