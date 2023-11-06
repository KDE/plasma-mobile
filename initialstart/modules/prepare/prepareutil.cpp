// SPDX-FileCopyrightText: 2023 by Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "prepareutil.h"

#include <kscreen/configmonitor.h>
#include <kscreen/getconfigoperation.h>
#include <kscreen/output.h>
#include <kscreen/setconfigoperation.h>

PrepareUtil::PrepareUtil(QObject *parent)
    : QObject{parent}
{
    connect(new KScreen::GetConfigOperation(), &KScreen::GetConfigOperation::finished, this, [this](auto *op) {
        m_config = qobject_cast<KScreen::GetConfigOperation *>(op)->config();

        int scaling = 100;

        // to determine the scaling value:
        // try to take the primary display's scaling, otherwise use the scaling of any of the displays
        for (KScreen::OutputPtr output : m_config->outputs()) {
            scaling = output->scale() * 100;
            if (output->isPrimary()) {
                break;
            }
        }

        m_scaling = scaling;
        Q_EMIT scalingChanged();
    });
}

int PrepareUtil::scaling() const
{
    return m_scaling;
}

void PrepareUtil::setScaling(int scaling)
{
    if (!m_config) {
        return;
    }

    const auto outputs = m_config->outputs();
    qreal scalingNum = ((double)scaling) / 100;

    for (KScreen::OutputPtr output : outputs) {
        output->setScale(scalingNum);
    }

    auto setop = new KScreen::SetConfigOperation(m_config, this);
    setop->exec();

    m_scaling = scaling;
    Q_EMIT scalingChanged();
}

QStringList PrepareUtil::scalingOptions()
{
    return {"50%", "100%", "150%", "200%", "250%", "300%"};
}
