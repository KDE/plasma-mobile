// SPDX-FileCopyrightText: 2023 by Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "prepareutil.h"

#include <QDebug>
#include <QRegularExpression>

PrepareUtil::PrepareUtil(QObject *parent)
    : QObject{parent}
    , m_process{new QProcess{this}}
{
    connect(m_process, QOverload<int, QProcess::ExitStatus>::of(&QProcess::finished), this, &PrepareUtil::receiveScalingFactor);

    // HACK: we are using kscreen-doctor to determine scaling, should switch to API
    m_process->start("kscreen-doctor", {"-o"});
}

int PrepareUtil::scaling() const
{
    return m_scaling;
}

void PrepareUtil::setScaling(int scaling)
{
    if (scaling != m_scaling) {
        const QString scalingNum = QString::number(((double)scaling) / 100);
        qDebug() << "scaling" << scalingNum;

        m_process->start("kscreen-doctor", {"output." + m_display + ".scale." + scalingNum});

        m_scaling = scaling;
        Q_EMIT scalingChanged();
    }
}

QStringList PrepareUtil::scalingOptions()
{
    return {"50%", "100%", "150%", "200%", "250%", "300%"};
}

void PrepareUtil::receiveScalingFactor(int exitCode, QProcess::ExitStatus exitStatus)
{
    Q_UNUSED(exitCode)
    Q_UNUSED(exitStatus)

    // only trigger this slot once, on first time
    disconnect(m_process, QOverload<int, QProcess::ExitStatus>::of(&QProcess::finished), this, &PrepareUtil::receiveScalingFactor);

    // remove ansi color codes
    const auto ansiEscape = QRegularExpression{"\\\u001B\\[.*?m"};
    const auto output = QString::fromUtf8(m_process->readAllStandardOutput()).replace(ansiEscape, "").replace("\\n", " ");
    auto split = output.split(" ");

    // HACK: hardcode how we get the output from kscreen-doctor
    // we assume the first display is the phone screen
    for (int i = 0; i < split.size(); ++i) {
        if (i == 2) {
            m_display = split[i];
        } else if (split[i] == "Scale:") {
            if (i + 1 < split.size()) {
                m_scaling = split[i + 1].toDouble() * 100;
                Q_EMIT scalingChanged();
            }

            break;
        }
    }
}
