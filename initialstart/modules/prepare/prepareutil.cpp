// SPDX-FileCopyrightText: 2023 by Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "prepareutil.h"

#include <kscreen/configmonitor.h>
#include <kscreen/getconfigoperation.h>
#include <kscreen/output.h>
#include <kscreen/setconfigoperation.h>

#include <QDBusPendingCallWatcher>
#include <QDBusPendingReply>
#include <QProcess>

PrepareUtil::PrepareUtil(QObject *parent)
    : QObject{parent}
    , m_colorsSettings{new ColorsSettings(this)}
{
    initKScreen([]() { });

    // set property initially
    m_usingDarkTheme = m_colorsSettings->colorScheme() == "BreezeDark";
}

void PrepareUtil::initKScreen(std::function<void()> callback)
{
    connect(new KScreen::GetConfigOperation(), &KScreen::GetConfigOperation::finished, this, [this, callback](auto *op) {
        m_config = qobject_cast<KScreen::GetConfigOperation *>(op)->config();

        if (!m_config) {
            return;
        }
        KScreen::ConfigMonitor::instance()->addConfig(m_config);

        int scaling = 100;

        // To determine the scaling value:
        // Try to take the primary display's scaling, otherwise use the scaling of any of the displays
        for (KScreen::OutputPtr output : m_config->outputs()) {
            if (!output) {
                continue;
            }
            scaling = output->scale() * 100;
            m_output = output->id();
            if (output->isPrimary()) {
                break;
            }
        }

        m_scaling = scaling;
        Q_EMIT scalingChanged();

        callback();
    });
}

int PrepareUtil::scaling() const
{
    return m_scaling;
}

void PrepareUtil::setScaling(int scaling)
{
    if (!m_config) {
        initKScreen([this, scaling]() {
            setScalingInternal(scaling);
        });
        return;
    }

    setScalingInternal(scaling);
}

void PrepareUtil::setScalingInternal(int scaling)
{
    const auto outputs = m_config->outputs();
    qreal scalingNum = ((double)scaling) / 100;

    for (KScreen::OutputPtr output : outputs) {
        if (!output) {
            continue;
        }
        if (output->id() == m_output) {
            output->setScale(scalingNum);
        }
    }

    auto setop = new KScreen::SetConfigOperation(m_config, this);
    setop->exec();

    m_scaling = scaling;
    Q_EMIT scalingChanged();
}

QStringList PrepareUtil::scalingOptions()
{
    return {"50%", "75%", "100%", "125%", "150%", "175%", "200%", "225%", "250%", "275%", "300%"};
}

bool PrepareUtil::usingDarkTheme() const
{
    return m_usingDarkTheme;
}

void PrepareUtil::setUsingDarkTheme(bool usingDarkTheme)
{
    // use plasma-apply-colorscheme since it has logic for notifying the shell of changes
    if (usingDarkTheme) {
        QProcess::execute("plasma-apply-colorscheme", {QStringLiteral("BreezeDark")});
    } else {
        QProcess::execute("plasma-apply-colorscheme", {QStringLiteral("BreezeLight")});
    }

    m_usingDarkTheme = usingDarkTheme;
    Q_EMIT usingDarkThemeChanged();
}
