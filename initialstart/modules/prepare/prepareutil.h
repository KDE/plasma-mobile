// SPDX-FileCopyrightText: 2023 by Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include <QObject>
#include <QProcess>
#include <qqmlregistration.h>

class PrepareUtil : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON
    Q_PROPERTY(int scaling READ scaling WRITE setScaling NOTIFY scalingChanged);
    Q_PROPERTY(QStringList scalingOptions READ scalingOptions CONSTANT);

public:
    PrepareUtil(QObject *parent = nullptr);

    int scaling() const;
    void setScaling(int scaling);

    QStringList scalingOptions();

Q_SIGNALS:
    void scalingChanged();

public Q_SLOTS:
    void receiveScalingFactor(int exitCode, QProcess::ExitStatus exitStatus);

private:
    int m_scaling;
    QString m_display;

    QProcess *m_process;
};
